import csv
import os 

# Функция CalcSum производит начисление
# Параметры
# type_calc - тип начичления, beginN - предыдущее показание счетчика, endN - текущее показания счетчика
def CalcSum(type_calc, beginN=0,endN=0):
    result = 0
    if (type_calc == '1'):      # Проверяем тип начисления
        result = st_norm        # Если один то присваиваем значение норматив
    else:       # По счетчику
        beginN = int(row["Предыдущее"])         # Рассчитываем разницу между текущим
        endN = int(row["Текущее"])              # и предыдущим
        result = (endN - beginN) * st_counter   # Вычисляем сумму
    return round(result,2)    

script_path = os.path.dirname(os.path.abspath(__file__))    # Путь к скрипту (здесь храняться файлы csv)
# Полные имена файлов (можно было бы передавать как парметры запуска, но такой задачи не ставится)
abon_csv = script_path + '\\' + 'абоненты.csv'              # Исходные данные
calc_abon = script_path + '\\' + 'Начисления_абоненты.csv'  # Начисления абонентов
calc_house = script_path + '\\' + 'Начисления_дома.csv'     # Начисления по домам
file_encoding = 'utf-8-sig'                                 # Кодировка символов, используемая в файлах

st_norm = 301.26    # Тариф по нормативу
st_counter = 1.52   # Тариф по счетчку

if __name__ == "__main__":  # Проверка является ли данный скрипт запускаемым, а не импортируемым

    #################### Задание 1 ###################

    with open(abon_csv, encoding=file_encoding) as r_file:
        
        file_reader = csv.DictReader(r_file, delimiter = ";")       # Создаем объект DictReader, указываем символ-разделитель ";"
        result_list = []            # Cписок для хранения результатов и дальнейшей записи в файл
        # Считывание данных из CSV файла
        for row in file_reader: # Перебор строк в файле как списка словарей при помощи цикла for
            type_calc = row["Тип начисления"]       # Получаем тип начисления
            beginN = int(row["Предыдущее"])         # Предыдущее 
            endN = int(row["Текущее"])              # и текущее показание

            sum = CalcSum(type_calc, beginN,endN)   
            row['Начислено'] = sum                   # Добавляем ключ-значение Начислено и записываем результат
            result_list.append(row)                  # Добавляем значение к списку результатов
            
    with open(calc_abon, mode="w", encoding=file_encoding) as w_file:     # файл для записи результатов
        headers = ["№ строки","Фамилия","Улица","№ дома","№ Квартиры","Тип начисления","Предыдущее","Текущее","Начислено"]  # Присваем значения заголовков
        file_writer = csv.DictWriter(w_file, delimiter = ";",                   # Открываем (создаем) файл для записи
                                    lineterminator="\r", fieldnames=headers)    # Используя метод DictWriter поскольку строки записи - словари
        file_writer.writeheader()      # Запись заголовков
        for row in result_list:        # Записываем результативный список при помощи цикла for
            file_writer.writerow(row)


    #################### Задание 2 ###################

    with open(abon_csv, encoding=file_encoding) as r_file:
        
        file_reader = csv.DictReader(r_file, delimiter = ";") # Создаем объект DictReader, указываем символ-разделитель ";"
        result_dict = {}        # Словать для хранения результатов и дальнейшей записи в файл 
        # Считывание данных из CSV файла
        for row in file_reader: # Перебор строк в файле как списка словарей при помощи цикла for
            type_calc = row["Тип начисления"]       # Получаем тип начисления
            beginN = int(row["Предыдущее"])         # Предыдущее 
            endN = int(row["Текущее"])              # и текущее показание
            street = row["Улица"]                   # Улицу
            house = row ["№ дома"]                  # Номер дома
            sum = CalcSum(type_calc, beginN,endN)   
            
            row['Начислено'] = sum                   # Добавляем ключ-значение Начислено и записываем результат
            if (street,house) in result_dict:        # Проверем имеется ли в словаре уже ключ "Улица, номер дома"
                result_dict[street,house] += round(sum)     # Если имеется - прибавляем сумму
            else:
                result_dict[street,house] = sum      # Иначе - добавляем элемент словаря с ключом "Улица, номер дома" и значением с суммой   
            
    with open(calc_house, mode="w", encoding='utf-8-sig') as w_file:                # файл для записи результатов
        headers = ["№ строки","Улица","Номер дома","Сумма"]                                    # Присваем значения заголовков
        file_writer = csv.writer(w_file, delimiter = ";",lineterminator="\r")       # Открываем (создаем) файл для записи, используя метод writer
        file_writer.writerow(headers)                                               # Записываем заголовки
        string_number = 1                                                           # Номер строки
        for key, val in result_dict.items():                                        # Записываем результативный списсок при помощи цикла for
            file_writer.writerow([string_number, key[0],key[1], val])               # Записываем как список значения словаря результатов (Номеро строки, Улица, Номер дома, сумма)
            string_number += 1                                                      # Наращиваем номер строки на 1 