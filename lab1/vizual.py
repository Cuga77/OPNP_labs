import base64
import requests

mermaid_code = """graph TD
    1((1)) --> 2{2}
    2 -->|True| 3{3}
    2 -->|False| 22((22))
    3 -->|True| 4((4))
    3 -->|False| 5{5}
    4 --> 21((21))
    5 -->|True| 6((6))
    5 -->|False| 7{7}
    6 --> 20((20))
    7 -->|True| 8((8))
    7 -->|False| 12((12))
    8 --> 9{9}
    9 -->|True| 10((10))
    9 -->|False| 11((11))
    10 --> 9
    11 --> 19((19))
    12 --> 13{13}
    13 -->|True| 14((14))
    13 -->|False| 15((15))
    14 --> 13
    15 --> 16{16}
    16 -->|True| 17((17))
    16 -->|False| 18((18))
    17 --> 16
    18 --> 19
    19 --> 20
    20 --> 21
    21 --> 2

    classDef normal fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000;
    classDef predicate fill:#e6e6e6,stroke:#000000,stroke-width:2px,color:#000000;
    
    class 1,4,6,8,10,11,12,14,15,17,18,19,20,21,22 normal;
    class 2,3,5,7,9,13,16 predicate;
"""

graph_bytes = mermaid_code.encode("utf8")
base64_string = base64.b64encode(graph_bytes).decode("ascii")

url = "https://mermaid.ink/img/" + base64_string

print(f"Прямая ссылка на обновленный граф программы (Вар 16): {url}\n")

try:
    response = requests.get(url, timeout=10)
    if response.status_code == 200:
        with open("graph_var16_program_new.png", "wb") as file:
            file.write(response.content)
        print("Готово! Картинка успешно сохранена в graph_var16_program_new.png")
    else:
        print(f"Сервер выдал ошибку: {response.status_code}")
except Exception as e:
    print("Сервер отвечает слишком долго. Зажмите Ctrl и кликните по ссылке выше для ручного сохранения!")