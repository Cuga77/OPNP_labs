import numpy as np
from PIL import Image
import cv2

def controller(control_drones):
    # Функция для поиска центров масс красных и синих объектов
    def get_com(img_cv, color):
        hsv = cv2.cvtColor(img_cv, cv2.COLOR_BGR2HSV)
        if color == 'red':
            # Красный цвет имеет два диапазона в HSV
            m1 = cv2.inRange(hsv, np.array([0, 70, 50]), np.array([10, 255, 255]))
            m2 = cv2.inRange(hsv, np.array([170, 70, 50]), np.array([180, 255, 255]))
            mask = m1 | m2
        else:
            # Синий цвет пути
            mask = cv2.inRange(hsv, np.array([100, 70, 50]), np.array([130, 255, 255]))
        
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if not contours: return None, mask
        c = max(contours, key=cv2.contourArea)
        if cv2.contourArea(c) < 20: return None, mask
        M = cv2.moments(c)
        if M["m00"] == 0: return None, mask
        return np.array([M["m10"] / M["m00"], M["m01"] / M["m00"]]), mask

    # 1. Автокалибровка осей камеры и дрона (занимает 3 шага)
    act0 = np.array([0.0, 0.0, 0.0])
    img0_pil = control_drones([act0])[0]
    img0 = cv2.cvtColor(np.array(img0_pil), cv2.COLOR_RGB2BGR)
    W, H = img0_pil.size
    cx, cy = W / 2.0, H / 2.0
    p0, _ = get_com(img0, 'red')

    act1 = np.array([0.2, 0.0, 0.0])
    img1 = cv2.cvtColor(np.array(control_drones([act1])[0]), cv2.COLOR_RGB2BGR)
    p1, _ = get_com(img1, 'red')

    act2 = np.array([0.0, 0.2, 0.0])
    img2 = cv2.cvtColor(np.array(control_drones([act2])[0]), cv2.COLOR_RGB2BGR)
    p2, _ = get_com(img2, 'red')

    # Расчет матрицы преобразования из пикселей в метры
    if p0 is not None and p1 is not None and p2 is not None:
        du_dx, dv_dx = (p1 - p0) / 0.2
        du_dy, dv_dy = (p2 - p1) / 0.2
        M = np.array([[du_dx, du_dy], [dv_dx, dv_dy]])
        M_inv = np.linalg.pinv(M)
        ppm = np.linalg.norm([du_dx, dv_dx]) # пикселей на метр
    else:
        M_inv = np.array([[-1/200.0, 0], [0, -1/200.0]])
        ppm = 200.0

    # Определение направления пути "вперед"
    b_com, _ = get_com(img2, 'blue')
    if b_com is not None and p2 is not None:
        V_dir = b_com - p2
        n = np.linalg.norm(V_dir)
        V_dir = V_dir / n if n > 0 else np.array([0.0, -1.0])
    else:
        V_dir = np.array([0.0, -1.0])

    X, Y = np.meshgrid(np.arange(W), np.arange(H))
    state = "HOVER"
    hover_frames = 0
    pos = np.array([0.2, 0.2]) # текущая позиция по XY
    last_square_pos = np.array([0.0, 0.0])
    action = np.array([0.0, 0.0, 0.0])

    # 2. Основной цикл навигации
    while True:
        img_pil = control_drones([action])[0]
        img_cv = cv2.cvtColor(np.array(img_pil), cv2.COLOR_RGB2BGR)
        r_com, _ = get_com(img_cv, 'red')
        b_com, b_mask = get_com(img_cv, 'blue')
        
        pos += action[:2]

        if state == "HOVER":
            if r_com is not None:
                err = np.linalg.norm(r_com - np.array([cx, cy]))
                if err < 0.15 * ppm: # отклонение в пределах нормы (менее 0.3м)
                    action = np.array([0.0, 0.0, 0.0])
                    hover_frames += 1
                else:
                    dxy = M_inv @ (np.array([cx, cy]) - r_com)
                    action = np.array([np.clip(dxy[0], -0.25, 0.25), np.clip(dxy[1], -0.25, 0.25), 0.0])
                    hover_frames = max(0, hover_frames - 1)

                # Зависание 4 секунды (примерно 6 шагов по 0.75с)
                if hover_frames >= 6:
                    state = "MOVE"
                    hover_frames = 0
                    last_square_pos = np.copy(pos)
            else:
                action = np.array([0.0, 0.0, 0.0])

        elif state == "MOVE":
            red_valid = False
            # Защита от повторного детектирования того же квадрата
            if r_com is not None and np.linalg.norm(pos - last_square_pos) > 1.2:
                dot = np.dot(r_com - np.array([cx, cy]), V_dir)
                if dot > -50: # квадрат находится по курсу движения
                    red_valid = True

            if red_valid:
                err = np.linalg.norm(r_com - np.array([cx, cy]))
                if err < 0.2 * ppm:
                    state = "HOVER"
                    action = np.array([0.0, 0.0, 0.0])
                    hover_frames = 1
                else:
                    dxy = M_inv @ (np.array([cx, cy]) - r_com)
                    n = np.linalg.norm(dxy)
                    if n > 0.4: dxy = dxy / n * 0.4
                    action = np.array([dxy[0], dxy[1], 0.0])
            else:
                # Полет вдоль синей линии
                dot_grid = (X - cx) * V_dir[0] + (Y - cy) * V_dir[1]
                forward_mask = (dot_grid > -30).astype(np.uint8) * 255
                f_blue = cv2.bitwise_and(b_mask, forward_mask)
                
                contours, _ = cv2.findContours(f_blue, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                if contours:
                    c = max(contours, key=cv2.contourArea)
                    M_blue = cv2.moments(c)
                    if M_blue["m00"] > 0:
                        f_b_com = np.array([M_blue["m10"] / M_blue["m00"], M_blue["m01"] / M_blue["m00"]])
                        target = f_b_com + V_dir * 80
                        dxy = M_inv @ (np.array([cx, cy]) - target)
                    else:
                        dxy = M_inv @ (-V_dir * 100)
                else:
                    dxy = M_inv @ (-V_dir * 100)

                n = np.linalg.norm(dxy)
                if n > 0.5: dxy = dxy / n * 0.5
                action = np.array([dxy[0], dxy[1], 0.0])