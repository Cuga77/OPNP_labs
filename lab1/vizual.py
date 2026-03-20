import base64
import requests

mermaid_code = """graph TD
    1{1} --> 2{2}
    1{1} --> 3((3))
    2{2} --> 4((4))
    2{2} --> 5{5}
    3((3)) --> 9((9))
    4((4)) --> 6{6}
    5{5} --> 7{7}
    5{5} --> 8((8))
    6{6} --> 7{7}
    6{6} --> 9((9))
    7{7} --> 8((8))
    7{7} --> 11((11))
    8((8)) --> 11((11))
    9((9)) --> 10((10))
    10((10)) --> 12{12}
    11((11)) --> 13{13}
    12{12} --> 10((10))
    12{12} --> 13{13}
    13{13} --> 9((9))
    13{13} --> 14((14))

    classDef normal fill:#ffffff,stroke:#000000,stroke-width:2px,color:#000000;
    classDef predicate fill:#e6e6e6,stroke:#000000,stroke-width:2px,color:#000000;
    
    class 3,4,8,9,10,11,14 normal;
    class 1,2,5,6,7,12,13 predicate;
"""

graph_bytes = mermaid_code.encode("utf8")
base64_string = base64.b64encode(graph_bytes).decode("ascii")

url = "https://mermaid.ink/img/" + base64_string

print(f"Прямая ссылка на обновленный граф: {url}\n")
print("Пробую скачать картинку автоматически...")

try:
    response = requests.get(url, timeout=10)
    if response.status_code == 200:
        with open("graph_var18_fixed.png", "wb") as file:
            file.write(response.content)
        print("Готово! Картинка успешно сохранена в graph_var18_fixed.png")
    else:
        print(f"Сервер выдал ошибку: {response.status_code}")
except Exception as e:
    print("Сервер отвечает слишком долго. Просто зажми Ctrl и кликни по ссылке выше, чтобы сохранить картинку вручную!")