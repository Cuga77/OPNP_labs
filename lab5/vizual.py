import base64
import requests

mermaid_code = """graph LR
    Info["Время: t = 2 ч<br/>Множитель: 10⁻⁵"] ~~~ Start((Вход))
    Start --- N1_1["λ₁ = 2.85"]
    N1_1 --- N1_2["λ₂ = 4.0"]
    N1_2 --- N1_3["λ₃ = 3.8"]
    N1_3 --- N1_4["λ₄ = 2.28"]

    N1_4 --- U1(( ))
    
    U1 --- N2_1a["λ = 2.0"]
    N2_1a --- N2_1b["λ = 2.0"]
    N2_1b --- U2(( ))

    U1 --- N2_2a["λ = 2.0"]
    N2_2a --- U2

    U2 --- N3_1a["μ = 2.8"]
    N3_1a --- N3_1b["μ = 2.8"]
    N3_1b --- N3_1c["μ = 2.8"]
    N3_1c --- U3(( ))

    U2 --- N3_2a["μ = 2.8"]
    N3_2a --- N3_2b["μ = 2.8"]
    N3_2b --- U3

    U3 --- End((Выход))

    classDef normal fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000;
    classDef point fill:#000000,stroke:#000000,stroke-width:0px;
    classDef info fill:#f9f9f9,stroke:#000000,stroke-width:1px,stroke-dasharray: 5 5;
    
    class N1_1,N1_2,N1_3,N1_4,N2_1a,N2_1b,N2_2a,N3_1a,N3_1b,N3_1c,N3_2a,N3_2b normal;
    class U1,U2,U3 point;
    class Info info;
"""

graph_bytes = mermaid_code.encode("utf8")
base64_string = base64.b64encode(graph_bytes).decode("ascii")

url = "https://mermaid.ink/img/" + base64_string + "?bgColor=!white"

print(f"Прямая ссылка на подробную схему (Вар 16): {url}\n")
print("Пробую скачать картинку автоматически...")

try:
    response = requests.get(url, timeout=10)
    if response.status_code == 200:
        with open("schema_var16_detailed.png", "wb") as file:
            file.write(response.content)
        print("Готово! Картинка успешно сохранена в schema_var16_detailed.png")
    else:
        print(f"Сервер выдал ошибку: {response.status_code}")
except Exception as e:
    print("Сервер отвечает слишком долго. Зажмите Ctrl и кликните по ссылке выше для ручного сохранения!")