#!/bin/bash
#Skrypt nalezy uruchomic z uprawnieniami root-a
#Lub tez zmienic uprawnienia do katalogu /etc/
if [ "$#" -ne 1 ]; then
	echo "Podaj sciezke do pliku jako argument"
	exit 1
fi

FILE_PATH="$1"
BASENAME=$(basename "$FILE_PATH")

if [[ "$BASENAME" == *.* ]]; then
	EXTENSION="${BASENAME##*.}"
else
	EXTENSION=""
fi

FILENAME="${BASENAME%.*}"
DATETIME=$(date +"%Y-%m-%d_%T")
BACKUP_DIR="/var/backup"

if [ ! -d "$BACKUP_DIR" ]; then
	mkdir -p "$BACKUP_DIR" 2>/dev/null
	if [ $? -eq 0 ]; then
		echo ""
	else
		echo "Blad : UPRAWNIENIA!"
		exit 1
	fi
	echo "Stworzono nowy katalog do backupow /var/backup"
fi

NEWFILE="${FILENAME}_${DATETIME}_backup.${EXTENSION}"

cp "$FILE_PATH" "$BACKUP_DIR/$NEWFILE" 2>/dev/null

if [ $? -eq 0 ]; then
	echo "Skopiowano pliki pomyslnie"
else
	echo "Blad : UPRAWNIENIA do kopiowania!"
	exit 1
fi

ORIGINAL_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')
BACKUP_HASH=$(sha256sum "$BACKUP_DIR/$NEWFILE" | awk '{print $1}')


CHECKSUM_FILE="${FILENAME}_${DATETIME}_checksum.txt"

echo "Oryginal : $FILE_PATH - SHA256: $ORIGINAL_HASH" > "$BACKUP_DIR/$CHECKSUM_FILE"
echo "Kopia : $NEWFILE - SHA256: $BACKUP_HASH" >> "$BACKUP_DIR/$CHECKSUM_FILE"

echo "Kopia obrazu oraz plik z sumami kontrolnymi utworzone w : $BACKUP_DIR"

if [ "$ORIGINAL_HASH" == "$BACKUP_HASH" ]; then
	echo "Suma kontrolna kopii jest identyczny jak oryginalu"
else
	echo "!!!UWAGA!!!"
	echo "Sumy kontrolne kopii i oryginalu sie nie zgadzaja!"
fi
	
