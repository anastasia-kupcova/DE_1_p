-- ============================================================
-- Демоэкзамен. Модуль 1. Подсистема "Продукция"
-- Производственная компания "Комфорт"
-- СУБД: MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS comfort_furniture
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE comfort_furniture;

-- ============================================================
-- 1. СПРАВОЧНИКИ
-- ============================================================

-- 1.1. Типы материалов
CREATE TABLE material_type (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255) NOT NULL UNIQUE,
    loss_percent  DECIMAL(6,4) NOT NULL
) ENGINE=InnoDB;

-- 1.2. Типы продукции
CREATE TABLE product_type (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(255) NOT NULL UNIQUE,
    coefficient  DECIMAL(6,2) NOT NULL
) ENGINE=InnoDB;

-- 1.3. Типы цехов
CREATE TABLE workshop_type (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ============================================================
-- 2. ОСНОВНЫЕ ТАБЛИЦЫ
-- ============================================================

-- 2.1. Цеха
CREATE TABLE workshop (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(255) NOT NULL UNIQUE,
    workshop_type_id  INT NOT NULL,
    people_count      INT NOT NULL,
    CONSTRAINT fk_workshop_type
        FOREIGN KEY (workshop_type_id) REFERENCES workshop_type(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 2.2. Материалы
CREATE TABLE material (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(255) NOT NULL UNIQUE,
    material_type_id  INT NOT NULL,
    CONSTRAINT fk_material_type
        FOREIGN KEY (material_type_id) REFERENCES material_type(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 2.3. Продукция
CREATE TABLE product (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    article           VARCHAR(50) NOT NULL,
    name              VARCHAR(255) NOT NULL,
    product_type_id   INT NOT NULL,
    min_price         DECIMAL(12,2) NOT NULL,
    main_material_id  INT NOT NULL,
    CONSTRAINT chk_min_price CHECK (min_price >= 0),
    CONSTRAINT fk_product_type
        FOREIGN KEY (product_type_id) REFERENCES product_type(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_product_material
        FOREIGN KEY (main_material_id) REFERENCES material(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================
-- 3. СВЯЗУЮЩАЯ ТАБЛИЦА (M:N)
-- ============================================================

-- 3.1. Продукция ↔ Цеха
CREATE TABLE product_workshop (
    product_id       INT NOT NULL,
    workshop_id      INT NOT NULL,
    production_time  DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (product_id, workshop_id),
    CONSTRAINT fk_pw_product
        FOREIGN KEY (product_id) REFERENCES product(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pw_workshop
        FOREIGN KEY (workshop_id) REFERENCES workshop(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================
-- 4. ЗАПОЛНЕНИЕ СПРАВОЧНИКОВ
-- ============================================================

-- 4.1. Типы материалов
INSERT INTO material_type (name, loss_percent) VALUES
('Мебельный щит из массива дерева', 0.0080),
('Ламинированное ДСП',              0.0070),
('Фанера',                          0.0055),
('МДФ',                             0.0030);

-- 4.2. Типы продукции
INSERT INTO product_type (name, coefficient) VALUES
('Гостиные',      3.50),
('Прихожие',      5.60),
('Мягкая мебель', 3.00),
('Кровати',       4.70),
('Шкафы',         1.50),
('Комоды',        2.30);

-- 4.3. Типы цехов
INSERT INTO workshop_type (name) VALUES
('Проектирование'),
('Обработка'),
('Сушка'),
('Сборка');

-- ============================================================
-- 5. ЗАПОЛНЕНИЕ ОСНОВНЫХ ТАБЛИЦ
-- ============================================================

-- 5.1. Цеха
INSERT INTO workshop (name, workshop_type_id, people_count) VALUES
('Проектный',                                                             1, 4),
('Расчетный',                                                             1, 5),
('Раскроя',                                                               2, 5),
('Обработки',                                                             2, 6),
('Сушильный',                                                             3, 3),
('Покраски',                                                              2, 5),
('Столярный',                                                             2, 7),
('Изготовления изделий из искусственного камня и композитных материалов', 2, 3),
('Изготовления мягкой мебели',                                            2, 5),
('Монтажа стеклянных, зеркальных вставок и других изделий',               4, 2),
('Сборки',                                                                4, 6),
('Упаковки',                                                              4, 4);

-- 5.2. Материалы (уникальные из Products_import.xlsx)
INSERT INTO material (name, material_type_id) VALUES
('Мебельный щит из массива дерева', 1),
('Ламинированное ДСП',              2),
('Фанера',                          3),
('МДФ',                             4);

-- 5.3. Продукция
INSERT INTO product (article, name, product_type_id, min_price, main_material_id) VALUES
-- Гостиные (product_type_id = 1)
('1549922', 'Комплект мебели для гостиной Ольха горная', 1, 160507.00, 1),
('1018556', 'Стенка для гостиной Вишня темная',          1, 216907.00, 1),
-- Прихожие (product_type_id = 2)
('3028272', 'Прихожая Венге Винтаж',                     2,  24970.00, 2),
('3029272', 'Тумба с вешалкой Дуб натуральный',          2,  18206.00, 2),
('3028248', 'Прихожая-комплект Дуб темный',              2, 177509.00, 1),
-- Мягкая мебель (product_type_id = 3)
('7118827', 'Диван-кровать угловой Книжка',              3,  85900.00, 1),
('7137981', 'Диван модульный Телескоп',                  3,  75900.00, 1),
('7029787', 'Диван-кровать Соло',                        3, 120345.00, 1),
('7758953', 'Детский диван Выкатной',                    3,  25990.00, 3),
-- Кровати (product_type_id = 4)
('6026662', 'Кровать с подъемным механизмом с матрасом 1600х2000 Венге', 4, 69500.00, 1),
('6159043', 'Кровать с матрасом 90х2000 Венге',                         4, 55600.00, 2),
('6588376', 'Кровать универсальная Дуб натуральный',                    4, 37900.00, 2),
('6758375', 'Кровать с ящиками Ясень белый',                            4, 46750.00, 3),
-- Шкафы (product_type_id = 5)
('2759324', 'Шкаф-купе 3-х дверный Сосна белая',       5, 131560.00, 2),
('2118827', 'Стеллаж Бук натуральный',                 5,  38700.00, 1),
('2559898', 'Шкаф 4 дверный с ящиками Ясень серый',    5, 160151.00, 3),
('2259474', 'Шкаф-пенал Береза белый',                 5,  40500.00, 3),
-- Комоды (product_type_id = 6)
('4115947', 'Комод 6 ящиков Вишня светлая',            6,  61235.00, 1),
('4033136', 'Комод 4 ящика Вишня светлая',             6,  41200.00, 1),
('4028048', 'Тумба под ТВ',                            6,  12350.00, 4);

-- ============================================================
-- 6. ЗАПОЛНЕНИЕ СВЯЗУЮЩЕЙ ТАБЛИЦЫ
-- ============================================================

INSERT INTO product_workshop (product_id, workshop_id, production_time)
SELECT p.id, w.id, src.production_time
FROM (
    SELECT 'Кровать с подъемным механизмом с матрасом 1600х2000 Венге' AS product_name,
           'Изготовления изделий из искусственного камня и композитных материалов' AS workshop_name,
           2.0 AS production_time
    UNION ALL SELECT 'Тумба под ТВ', 'Изготовления изделий из искусственного камня и композитных материалов', 2.7
    UNION ALL SELECT 'Диван-кровать угловой Книжка', 'Изготовления мягкой мебели', 4.2
    UNION ALL SELECT 'Диван модульный Телескоп', 'Изготовления мягкой мебели', 4.5
    UNION ALL SELECT 'Диван-кровать Соло', 'Изготовления мягкой мебели', 4.7
    UNION ALL SELECT 'Детский диван Выкатной', 'Изготовления мягкой мебели', 4.0
    UNION ALL SELECT 'Кровать с матрасом 90х2000 Венге', 'Изготовления мягкой мебели', 5.5
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Монтажа стеклянных, зеркальных вставок и других изделий', 0.3
    UNION ALL SELECT 'Прихожая Венге Винтаж', 'Монтажа стеклянных, зеркальных вставок и других изделий', 0.5
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Монтажа стеклянных, зеркальных вставок и других изделий', 0.3
    UNION ALL SELECT 'Кровать с подъемным механизмом с матрасом 1600х2000 Венге', 'Монтажа стеклянных, зеркальных вставок и других изделий', 0.5
    UNION ALL SELECT 'Шкаф-купе 3-х дверный Сосна белая', 'Монтажа стеклянных, зеркальных вставок и других изделий', 0.5
    UNION ALL SELECT 'Тумба под ТВ', 'Монтажа стеклянных, зеркальных вставок и других изделий', 1.0
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Обработки', 0.5
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Обработки', 0.3
    UNION ALL SELECT 'Прихожая Венге Винтаж', 'Обработки', 0.5
    UNION ALL SELECT 'Тумба с вешалкой Дуб натуральный', 'Обработки', 0.5
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Обработки', 0.5
    UNION ALL SELECT 'Диван-кровать угловой Книжка', 'Обработки', 0.5
    UNION ALL SELECT 'Диван модульный Телескоп', 'Обработки', 0.5
    UNION ALL SELECT 'Диван-кровать Соло', 'Обработки', 0.5
    UNION ALL SELECT 'Детский диван Выкатной', 'Обработки', 0.3
    UNION ALL SELECT 'Кровать с подъемным механизмом с матрасом 1600х2000 Венге', 'Обработки', 0.6
    UNION ALL SELECT 'Кровать с матрасом 90х2000 Венге', 'Обработки', 1.0
    UNION ALL SELECT 'Кровать универсальная Дуб натуральный', 'Обработки', 0.8
    UNION ALL SELECT 'Кровать с ящиками Ясень белый', 'Обработки', 2.0
    UNION ALL SELECT 'Шкаф-купе 3-х дверный Сосна белая', 'Обработки', 0.5
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Обработки', 0.3
    UNION ALL SELECT 'Шкаф 4 дверный с ящиками Ясень серый', 'Обработки', 1.5
    UNION ALL SELECT 'Шкаф-пенал Береза белый', 'Обработки', 1.0
    UNION ALL SELECT 'Комод 6 ящиков Вишня светлая', 'Обработки', 0.5
    UNION ALL SELECT 'Комод 4 ящика Вишня светлая', 'Обработки', 0.4
    UNION ALL SELECT 'Тумба под ТВ', 'Обработки', 0.5
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Покраски', 0.3
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Покраски', 0.4
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Покраски', 0.5
    UNION ALL SELECT 'Диван-кровать угловой Книжка', 'Покраски', 0.5
    UNION ALL SELECT 'Диван модульный Телескоп', 'Покраски', 1.0
    UNION ALL SELECT 'Диван-кровать Соло', 'Покраски', 0.5
    UNION ALL SELECT 'Детский диван Выкатной', 'Покраски', 0.5
    UNION ALL SELECT 'Кровать с подъемным механизмом с матрасом 1600х2000 Венге', 'Покраски', 0.4
    UNION ALL SELECT 'Кровать с ящиками Ясень белый', 'Покраски', 1.5
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Покраски', 1.0
    UNION ALL SELECT 'Шкаф-пенал Береза белый', 'Покраски', 2.5
    UNION ALL SELECT 'Комод 6 ящиков Вишня светлая', 'Покраски', 1.0
    UNION ALL SELECT 'Комод 4 ящика Вишня светлая', 'Покраски', 0.4
    UNION ALL SELECT 'Тумба под ТВ', 'Покраски', 0.5
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Проектный', 1.0
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Проектный', 1.0
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Проектный', 1.5
    UNION ALL SELECT 'Диван-кровать Соло', 'Проектный', 0.5
    UNION ALL SELECT 'Шкаф-купе 3-х дверный Сосна белая', 'Проектный', 2.0
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Проектный', 1.0
    UNION ALL SELECT 'Тумба под ТВ', 'Проектный', 1.0
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Раскроя', 1.0
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Раскроя', 1.0
    UNION ALL SELECT 'Прихожая Венге Винтаж', 'Раскроя', 1.0
    UNION ALL SELECT 'Тумба с вешалкой Дуб натуральный', 'Раскроя', 1.0
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Раскроя', 1.0
    UNION ALL SELECT 'Диван-кровать угловой Книжка', 'Раскроя', 1.0
    UNION ALL SELECT 'Диван модульный Телескоп', 'Раскроя', 1.0
    UNION ALL SELECT 'Диван-кровать Соло', 'Раскроя', 0.5
    UNION ALL SELECT 'Детский диван Выкатной', 'Раскроя', 0.7
    UNION ALL SELECT 'Кровать с подъемным механизмом с матрасом 1600х2000 Венге', 'Раскроя', 1.0
    UNION ALL SELECT 'Кровать с матрасом 90х2000 Венге', 'Раскроя', 1.0
    UNION ALL SELECT 'Кровать универсальная Дуб натуральный', 'Раскроя', 1.1
    UNION ALL SELECT 'Кровать с ящиками Ясень белый', 'Раскроя', 2.0
    UNION ALL SELECT 'Шкаф-купе 3-х дверный Сосна белая', 'Раскроя', 1.0
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Раскроя', 1.0
    UNION ALL SELECT 'Шкаф 4 дверный с ящиками Ясень серый', 'Раскроя', 1.0
    UNION ALL SELECT 'Шкаф-пенал Береза белый', 'Раскроя', 1.0
    UNION ALL SELECT 'Комод 6 ящиков Вишня светлая', 'Раскроя', 1.0
    UNION ALL SELECT 'Комод 4 ящика Вишня светлая', 'Раскроя', 1.0
    UNION ALL SELECT 'Тумба под ТВ', 'Раскроя', 0.6
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Расчетный', 0.4
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Расчетный', 1.0
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Расчетный', 0.5
    UNION ALL SELECT 'Диван-кровать Соло', 'Расчетный', 0.5
    UNION ALL SELECT 'Шкаф-купе 3-х дверный Сосна белая', 'Расчетный', 1.0
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Расчетный', 0.7
    UNION ALL SELECT 'Тумба под ТВ', 'Расчетный', 0.4
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Сборки', 1.0
    UNION ALL SELECT 'Прихожая Венге Винтаж', 'Сборки', 1.0
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Сборки', 0.5
    UNION ALL SELECT 'Диван-кровать угловой Книжка', 'Сборки', 0.5
    UNION ALL SELECT 'Диван модульный Телескоп', 'Сборки', 0.3
    UNION ALL SELECT 'Кровать универсальная Дуб натуральный', 'Сборки', 0.8
    UNION ALL SELECT 'Кровать с ящиками Ясень белый', 'Сборки', 0.3
    UNION ALL SELECT 'Шкаф-купе 3-х дверный Сосна белая', 'Сборки', 1.5
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Сборки', 0.3
    UNION ALL SELECT 'Шкаф 4 дверный с ящиками Ясень серый', 'Сборки', 2.0
    UNION ALL SELECT 'Комод 6 ящиков Вишня светлая', 'Сборки', 0.3
    UNION ALL SELECT 'Тумба под ТВ', 'Сборки', 1.0
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Столярный', 1.5
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Столярный', 1.0
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Столярный', 1.0
    UNION ALL SELECT 'Диван модульный Телескоп', 'Столярный', 0.5
    UNION ALL SELECT 'Диван-кровать Соло', 'Столярный', 0.5
    UNION ALL SELECT 'Детский диван Выкатной', 'Столярный', 1.0
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Столярный', 0.5
    UNION ALL SELECT 'Шкаф 4 дверный с ящиками Ясень серый', 'Столярный', 1.0
    UNION ALL SELECT 'Шкаф-пенал Береза белый', 'Столярный', 3.0
    UNION ALL SELECT 'Комод 6 ящиков Вишня светлая', 'Столярный', 2.0
    UNION ALL SELECT 'Комод 4 ящика Вишня светлая', 'Столярный', 2.0
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Сушильный', 2.0
    UNION ALL SELECT 'Стенка для гостиной Вишня темная', 'Сушильный', 2.0
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Сушильный', 2.0
    UNION ALL SELECT 'Диван-кровать угловой Книжка', 'Сушильный', 2.0
    UNION ALL SELECT 'Диван модульный Телескоп', 'Сушильный', 2.0
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Сушильный', 2.0
    UNION ALL SELECT 'Комод 6 ящиков Вишня светлая', 'Сушильный', 2.0
    UNION ALL SELECT 'Комод 4 ящика Вишня светлая', 'Сушильный', 2.0
    UNION ALL SELECT 'Комплект мебели для гостиной Ольха горная', 'Упаковки', 0.3
    UNION ALL SELECT 'Тумба с вешалкой Дуб натуральный', 'Упаковки', 0.5
    UNION ALL SELECT 'Прихожая-комплект Дуб темный', 'Упаковки', 0.2
    UNION ALL SELECT 'Диван-кровать угловой Книжка', 'Упаковки', 0.3
    UNION ALL SELECT 'Диван модульный Телескоп', 'Упаковки', 0.2
    UNION ALL SELECT 'Диван-кровать Соло', 'Упаковки', 0.3
    UNION ALL SELECT 'Детский диван Выкатной', 'Упаковки', 0.5
    UNION ALL SELECT 'Кровать с подъемным механизмом с матрасом 1600х2000 Венге', 'Упаковки', 0.5
    UNION ALL SELECT 'Кровать с матрасом 90х2000 Венге', 'Упаковки', 0.5
    UNION ALL SELECT 'Кровать универсальная Дуб натуральный', 'Упаковки', 0.3
    UNION ALL SELECT 'Кровать с ящиками Ясень белый', 'Упаковки', 0.2
    UNION ALL SELECT 'Шкаф-купе 3-х дверный Сосна белая', 'Упаковки', 0.5
    UNION ALL SELECT 'Стеллаж Бук натуральный', 'Упаковки', 0.2
    UNION ALL SELECT 'Шкаф 4 дверный с ящиками Ясень серый', 'Упаковки', 0.5
    UNION ALL SELECT 'Шкаф-пенал Береза белый', 'Упаковки', 0.5
    UNION ALL SELECT 'Комод 6 ящиков Вишня светлая', 'Упаковки', 0.2
    UNION ALL SELECT 'Комод 4 ящика Вишня светлая', 'Упаковки', 0.2
    UNION ALL SELECT 'Тумба под ТВ', 'Упаковки', 0.3
) AS src
JOIN product  p ON p.name = src.product_name
JOIN workshop w ON w.name = src.workshop_name;

-- ============================================================
-- 7. ПРОВЕРКА
-- ============================================================

SELECT 'material_type'   AS table_name, COUNT(*) AS rows_count FROM material_type
UNION ALL SELECT 'product_type',     COUNT(*) FROM product_type
UNION ALL SELECT 'workshop_type',    COUNT(*) FROM workshop_type
UNION ALL SELECT 'workshop',         COUNT(*) FROM workshop
UNION ALL SELECT 'material',         COUNT(*) FROM material
UNION ALL SELECT 'product',          COUNT(*) FROM product
UNION ALL SELECT 'product_workshop', COUNT(*) FROM product_workshop;