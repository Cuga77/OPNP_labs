import matplotlib
matplotlib.use('Agg')  # сохраняем в файл без GUI
import networkx as nx
import matplotlib.pyplot as plt

# Создаём направленный граф
G = nx.DiGraph()

# Подписи узлов (как в вашей mermaid-схеме)
labels = {
    'Start': 'Вход',
    'N1_1': 'N1_1\n(1.8)',
    'N1_2': 'N1_2\n(4.0)',
    'N1_3': 'N1_3\n(2.2)',
    'N2_1a': 'N2_1a\n(4.0)',
    'N2_1b': 'N2_1b\n(4.0)',
    'N2_2a': 'N2_2a\n(4.0)',
    'N2_2b': 'N2_2b\n(4.0)',
    'Node1': 'Узел',
    'N3_1a': 'N3_1a\n(2.2)',
    'N3_1b': 'N3_1b\n(2.2)',
    'N3_1c': 'N3_1c\n(2.2)',
    'N3_2a': 'N3_2a\n(2.2)',
    'End': 'Выход'
}

# Добавляем узлы
for node in labels:
    G.add_node(node)

# Рёбра согласно схеме
edges = [
    ('Start', 'N1_1'),
    ('N1_1', 'N1_2'),
    ('N1_2', 'N1_3'),
    ('N1_3', 'N2_1a'),
    ('N1_3', 'N2_2a'),
    ('N2_1a', 'N2_1b'),
    ('N2_2a', 'N2_2b'),
    ('N2_1b', 'Node1'),
    ('N2_2b', 'Node1'),
    ('Node1', 'N3_1a'),
    ('Node1', 'N3_2a'),
    ('N3_1a', 'N3_1b'),
    ('N3_1b', 'N3_1c'),
    ('N3_1c', 'End'),
    ('N3_2a', 'End')
]
G.add_edges_from(edges)

# Компактные координаты (расстояния уменьшены)
pos = {
    'Start': (0, 0),
    'N1_1': (1.2, 0),
    'N1_2': (2.4, 0),
    'N1_3': (3.6, 0),
    'N2_1a': (4.8, 0.7),
    'N2_1b': (6.0, 0.7),
    'N2_2a': (4.8, -0.7),
    'N2_2b': (6.0, -0.7),
    'Node1': (7.2, 0),
    'N3_1a': (8.4, 0.7),
    'N3_1b': (9.6, 0.7),
    'N3_1c': (10.8, 0.7),
    'N3_2a': (8.4, -0.7),
    'End': (12.0, 0)
}

# Чёрно-белое оформление
plt.figure(figsize=(12, 4))          # компактный размер

nx.draw(G, pos,
        with_labels=False,
        node_shape='s',              # прямоугольники (квадраты)
        node_size=1800,              # чуть меньше для компактности
        node_color='white',          # белая заливка
        edge_color='black',          # чёрные стрелки
        linewidths=1.5,              # толщина границы узлов
        width=1.2,                   # толщина рёбер
        arrows=True,
        arrowsize=15,
        arrowstyle='-|>')

# Подписи внутри узлов (чёрным шрифтом)
nx.draw_networkx_labels(G, pos, labels, font_size=8, font_weight='bold')

plt.title("Структурная схема системы", fontsize=12, fontweight='bold')
plt.axis('off')
plt.tight_layout()

# Сохраняем в файл
plt.savefig('graph_scheme.png', dpi=300, bbox_inches='tight', facecolor='white')
print("Схема сохранена как graph_scheme.png")