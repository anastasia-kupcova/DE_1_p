using System;
using System.Data;
using System.Windows.Forms;
using MySql.Data.MySqlClient;

namespace Mebel_magaz
{
    public partial class WorkshopsForm : Form
    {
        private string connStr = "Server=localhost;Database=comfort_furniture;Uid=root;Pwd=234789%Flol&;";

        // Конструктор принимает ID продукта и его название
        public WorkshopsForm(int productId, string productName)
        {
            InitializeComponent();
            lblProductName.Text = $"Цеха для производства: {productName}";
            LoadWorkshops(productId);
        }

        private void LoadWorkshops(int productId)
        {
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    // SQL запрос: берем цеха и время изготовления именно для этого продукта
                    string query = @"
                        SELECT 
                            w.name AS 'Название цеха', 
                            w.people_count AS 'Кол-во человек', 
                            pw.production_time AS 'Время (ч)'
                        FROM product_workshop pw
                        JOIN workshop w ON pw.workshop_id = w.id
                        WHERE pw.product_id = @productId
                        ORDER BY w.name;";

                    using (MySqlCommand cmd = new MySqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@productId", productId);

                        using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            adapter.Fill(dt);
                            dgvWorkshops.DataSource = dt;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка загрузки цехов: " + ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}