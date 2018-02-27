# backup-bash
Дифференциальное непрерывное резервное

копирование

В файле config находятся строки вида (несколько строк):

{[+|­]size} {pattern} {/каталог/}

Требуется реализовать утилиту дифференциального непрерывного резервного

копирования данных, которая работает по конфигурационному файлу, т.е. на файлах в

каталогах (рекурсивно) из конфигурационного файла, которые отвечают критериям

размера ([+|-­|=|size] = больше, меньше, равно) и шаблону имени (pattern).

При первичном нахождении файла (рекурсивно относительно каталога из

конфигурационного файла) и отсутствия его в архиве утилита помещает файл в архив.

В том случае, если при очередном осмотре утилита определила, что файл изменился по

содержимому (определение с помощью diff, то есть он отличается от файла в архиве), то

она складывает patch­файл (diff между двумя версиями файла (оригинальной в архиве и

текущей) в формате patch) в архив, сохраняя каталожную иерархию (то есть в тот же

каталог, где хранится в архиве базовая версия файла), при этом к имени файла

добавляется расширение “.{time}.patch”, где time ­ число секунд прошедшее с начала

эпохи Unix (см. date).

Утилита резервного копирования работает в вечном цикле с паузой между итерациями ­ 2

секунды.

Так же требуется реализовать утилиту восстановления файла на указанное время time

путем применения к исходному файлу патча с меткой времени наиболее близко

находящейся к времени восстановления, но до ее (меньше времени восстановления).

Входные аргументы команды:

­ исходный файл (путь в архиве)

­ время восстановления в формате unix epoch, если не указано, то

восстанавливается наиболее свежаая.

./restore­file path/to/file [unixtime]

Выход работы программы ­ целевой файл (stdout), полученный применением патча.
