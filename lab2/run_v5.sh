#!/bin/bash

set -e

OUT_DIR="variant_5_larukova_style"
mkdir -p "$OUT_DIR"

echo "Компиляция исходных файлов..."
gcc -I./sampler/libsampler bubble_mode1.c ./sampler/build/libsampler/libsampler.a -o bubble_mode1 -lm
gcc -I./sampler/libsampler bubble_mode2.c ./sampler/build/libsampler/libsampler.a -o bubble_mode2 -lm
gcc -I./sampler/libsampler bubble_mode2_opt.c ./sampler/build/libsampler/libsampler.a -o bubble_mode2_opt -lm

echo "Профилирование Режима 1 (500 запусков, 100 пропусков)..."
taskset -c 0 ./sampler/build/tools/repeat 500 100 ./bubble_mode1 > "$OUT_DIR/raw_mode1.txt"
python3 ./sampler/tools/process.py < "$OUT_DIR/raw_mode1.txt" > "$OUT_DIR/processed_mode1.txt"
./sampler/tools/fmttable < "$OUT_DIR/processed_mode1.txt" > "$OUT_DIR/table_mode1.txt"

echo "Профилирование Режима 2 (1000 запусков, 200 пропусков)..."
taskset -c 0 ./sampler/build/tools/repeat 1000 200 ./bubble_mode2 > "$OUT_DIR/raw_mode2.txt"
python3 ./sampler/tools/process.py < "$OUT_DIR/raw_mode2.txt" > "$OUT_DIR/processed_mode2.txt"
./sampler/tools/fmttable < "$OUT_DIR/processed_mode2.txt" > "$OUT_DIR/table_mode2.txt"
./sampler/tools/fmtdot < "$OUT_DIR/processed_mode2.txt" > "$OUT_DIR/graph_mode2.dot"
dot -Tpng "$OUT_DIR/graph_mode2.dot" -o "$OUT_DIR/graph_mode2.png"

echo "Профилирование оптимизированной версии (1000 запусков, 200 пропусков)..."
taskset -c 0 ./sampler/build/tools/repeat 1000 200 ./bubble_mode2_opt > "$OUT_DIR/raw_opt.txt"
python3 ./sampler/tools/process.py < "$OUT_DIR/raw_opt.txt" > "$OUT_DIR/processed_opt.txt"
./sampler/tools/fmttable < "$OUT_DIR/processed_opt.txt" > "$OUT_DIR/table_opt.txt"
./sampler/tools/fmtdot < "$OUT_DIR/processed_opt.txt" > "$OUT_DIR/graph_opt.dot"
dot -Tpng "$OUT_DIR/graph_opt.dot" -o "$OUT_DIR/graph_opt.png"

echo "Готово! Результаты сохранены в $OUT_DIR."