using System;
using System.Collections.Generic;
using MySql.Data.MySqlClient;
using Mebel_magaz.Models;

namespace Mebel_magaz.Data
{
    public class DbHelper
    {
        // Строка подключения
        private string connStr = "Server=localhost;Database=comfort_furniture;Uid=root;Pwd=234789%Flol&;";

        // Метод получения списка продукции
        public List<Product> GetProducts()
        {
            List<Product> products = new List<Product>();

            // SQL запрос: соединяем таблицы и суммируем время по цехам
            string query = @"
                SELECT 
                    p.id, 
                    p.article, 
                    p.name, 
                    pt.name AS product_type, 
                    p.min_price, 
                    m.name AS main_material,
                    COALESCE(SUM(pw.production_time), 0) AS total_time
                FROM product p
                JOIN product_type pt ON p.product_type_id = pt.id
                JOIN material m ON p.main_material_id = m.id
                LEFT JOIN product_workshop pw ON p.id = pw.product_id
                GROUP BY p.id, p.article, p.name, pt.name, p.min_price, m.name
                ORDER BY pt.name, p.name;";

            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    using (MySqlCommand cmd = new MySqlCommand(query, conn))
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(new Product
                            {
                                Id = reader.GetInt32("id"),
                                Article = reader.GetString("article"),
                                Name = reader.GetString("name"),
                                ProductType = reader.GetString("product_type"),
                                MinPrice = reader.GetDecimal("min_price"),
                                MainMaterial = reader.GetString("main_material"),
                                // По заданию время должно быть целым. 
                                // Округляем сумму (например 4.2 + 0.5 = 4.7 -> 5 часов)
                                TotalTime = (int)Math.Round(reader.GetDecimal("total_time"), MidpointRounding.AwayFromZero)
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Если что-то пошло не так, пробрасываем ошибку наверх в форму
                throw new Exception("Ошибка при загрузке данных из БД: " + ex.Message);
            }

            return products;
        }
        // Получить словарь типов продукции (ID -> Название)
        public Dictionary<int, string> GetProductTypes()
        {
            var types = new Dictionary<int, string>();
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string query = "SELECT id, name FROM product_type ORDER BY name";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        types.Add(reader.GetInt32("id"), reader.GetString("name"));
                }
            }
            return types;
        }

        // Получить словарь материалов (ID -> Название)
        public Dictionary<int, string> GetMaterials()
        {
            var materials = new Dictionary<int, string>();
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string query = "SELECT id, name FROM material ORDER BY name";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        materials.Add(reader.GetInt32("id"), reader.GetString("name"));
                }
            }
            return materials;
        }

        // Метод добавления/обновления продукта. 
        // Если productId == 0, значит добавление, иначе - обновление
        public void SaveProduct(int productId, string article, string name, int typeId, decimal price, int materialId)
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string query = productId == 0
                    ? @"INSERT INTO product (article, name, product_type_id, min_price, main_material_id) 
                        VALUES (@article, @name, @typeId, @price, @materialId)"
                    : @"UPDATE product SET article=@article, name=@name, product_type_id=@typeId, 
                        min_price=@price, main_material_id=@materialId WHERE id=@id";

                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@article", article);
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@typeId", typeId);
                    cmd.Parameters.AddWithValue("@price", price);
                    cmd.Parameters.AddWithValue("@materialId", materialId);
                    if (productId != 0) cmd.Parameters.AddWithValue("@id", productId);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        // Получить один продукт по ID (для заполнения формы при редактировании)
        public Product GetProductById(int id)
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string query = "SELECT article, name, product_type_id, min_price, main_material_id FROM product WHERE id = @id";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new Product
                            {
                                Id = id,
                                Article = reader.GetString("article"),
                                Name = reader.GetString("name"),
                                ProductType = reader.GetInt32("product_type_id").ToString(), // Временно храним ID типа
                                MinPrice = reader.GetDecimal("min_price"),
                                MainMaterial = reader.GetInt32("main_material_id").ToString() // Временно ID материала
                            };
                        }
                    }
                }
            }
            return null;
        }
    }
}