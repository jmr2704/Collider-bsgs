#!/bin/bash
echo "=========================================="
echo "      Compilador Jacazul - Collider (Linux)"
echo "=========================================="
echo ""
read -p "Digite o nome do executavel (ex: Collider_BR10) ou de enter para 'Collider_BR': " OUT_NAME

if [ -z "$OUT_NAME" ]; then
    OUT_NAME="Collider_BR"
fi

PB_COMPILER="pbcompiler"

if ! command -v $PB_COMPILER &> /dev/null
then
    if [ -f "/opt/purebasic/compilers/pbcompiler" ]; then
        PB_COMPILER="/opt/purebasic/compilers/pbcompiler"
    else
        echo "[ERRO] O pbcompiler nao foi encontrado!"
        echo "Adicione o PureBasic ao seu PATH ou edite este script."
        exit 1
    fi
fi

echo ""
echo "[INFO] Compilando Collider.pb para -> ../x64/$OUT_NAME"
echo "[INFO] Usando compilador: $PB_COMPILER"
echo ""

$PB_COMPILER Collider.pb -e "../x64/$OUT_NAME" -t -c

if [ $? -eq 0 ]; then
    echo ""
    echo "[SUCESSO] $OUT_NAME compilado e pronto pro abate!"
else
    echo ""
    echo "[ERRO] A compilacao falhou. De uma olhada no console acima."
fi
