using System;

namespace Mebel_magaz.Utils
{
    public class RawMaterialCalculator
    {
        /// <summary>
        /// Метод расчета количества сырья с учетом потерь.
        /// </summary>
        /// <param name="productTypeId">ID типа продукции</param>
        /// <param name="materialTypeId">ID типа материала</param>
        /// <param name="quantity">Количество продукции (целое)</param>
        /// <param name="param1">Параметр 1 (вещественный)</param>
        /// <param name="param2">Параметр 2 (вещественный)</param>
        /// <returns>Целое количество сырья, либо -1 при ошибке</returns>
        public static int Calculate(int productTypeId, int materialTypeId, int quantity, double param1, double param2)
        {
            // Валидация входных данных (если данные некорректны — возвращаем -1)
            if (quantity <= 0 || param1 <= 0 || param2 <= 0)
                return -1;

            // Пример коэффициентов (в реальной программе они берутся из БД, 
            // но для метода-алгоритма можно захардкодить или передать)
            double productCoefficient = GetProductCoefficient(productTypeId);
            double materialLossPercent = GetMaterialLossPercent(materialTypeId);

            if (productCoefficient <= 0 || materialLossPercent <= 0)
                return -1; // Несуществующие типы

            // 1. Сырье на одну единицу = произведение параметров * коэффициент
            double rawPerUnit = param1 * param2 * productCoefficient;

            // 2. Общее сырье = на единицу * количество
            double totalRaw = rawPerUnit * quantity;

            // 3. Увеличение с учетом потерь (потери 0.008 = 0.8%)
            totalRaw = totalRaw * (1 + materialLossPercent);

            // Возвращаем целое количество (округляем вверх, чтобы сырья точно хватило)
            return (int)Math.Ceiling(totalRaw);
        }

        // Заглушки для получения коэффициентов (в реальности — SELECT из БД)
        private static double GetProductCoefficient(int id)
        {
            switch (id)
            {
                case 1: return 3.5;  // Гостиные
                case 2: return 5.6;  // Прихожие
                case 3: return 3.0;  // Мягкая мебель
                case 4: return 4.7;  // Кровати
                case 5: return 1.5;  // Шкафы
                case 6: return 2.3;  // Комоды
                default: return -1;
            }
        }

        private static double GetMaterialLossPercent(int id)
        {
            switch (id)
            {
                case 1: return 0.008;  // Мебельный щит
                case 2: return 0.007;  // ЛДСП
                case 3: return 0.0055; // Фанера
                case 4: return 0.003;  // МДФ
                default: return -1;
            }
        }
    }
}