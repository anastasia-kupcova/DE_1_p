using Mebel_magaz.Data;
using Mebel_magaz.Models;
using System;
using System.Windows.Forms;

namespace Mebel_magaz
{
    public partial class ProductEditForm : Form
    {
        private DbHelper dbHelper = new DbHelper();
        private int currentProductId = 0; // 0 = добавление, >0 = редактирование

        // Конструктор для ДОБАВЛЕНИЯ
        public ProductEditForm()
        {
            InitializeComponent();
            Text = "Добавление продукции"; // Заголовок окна
            currentProductId = 0;
            LoadComboBoxes();

            this.btnSave.Click += new EventHandler(this.btnSave_Click);
        }

        // Конструктор для РЕДАКТИРОВАНИЯ
        public ProductEditForm(int productId)
        {
            InitializeComponent();
            Text = "Редактирование продукции";
            currentProductId = productId;
            LoadComboBoxes();
            LoadProductData();

            this.btnSave.Click += new EventHandler(this.btnSave_Click);
        }

        // Заполняем выпадающие списки из БД
        private void LoadComboBoxes()
        {
            try
            {
                cmbProductType.DataSource = new BindingSource(dbHelper.GetProductTypes(), null);
                cmbProductType.DisplayMember = "Value";
                cmbProductType.ValueMember = "Key";

                cmbMaterial.DataSource = new BindingSource(dbHelper.GetMaterials(), null);
                cmbMaterial.DisplayMember = "Value";
                cmbMaterial.ValueMember = "Key";
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка загрузки справочников: " + ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // Загружаем данные продукта в поля (для редактирования)
        private void LoadProductData()
        {
            try
            {
                Product prod = dbHelper.GetProductById(currentProductId);
                if (prod != null)
                {
                    txtArticle.Text = prod.Article;
                    txtName.Text = prod.Name;
                    txtPrice.Text = prod.MinPrice.ToString("0.00");

                    // Устанавливаем выбранные значения в ComboBox по ID
                    cmbProductType.SelectedValue = int.Parse(prod.ProductType);
                    cmbMaterial.SelectedValue = int.Parse(prod.MainMaterial);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка загрузки данных продукта: " + ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // Обработка кнопки "Сохранить"
        private void btnSave_Click(object sender, EventArgs e)
        {
            
            // 1. ПРОВЕРКА НА ЗАПОЛНЕНИЕ (Валидация)
            if (string.IsNullOrWhiteSpace(txtArticle.Text))
            {
                MessageBox.Show("Введите артикул продукции.", "Ошибка заполнения", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            if (string.IsNullOrWhiteSpace(txtName.Text))
            {
                MessageBox.Show("Введите наименование продукции.", "Ошибка заполнения", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            if (cmbProductType.SelectedValue == null)
            {
                MessageBox.Show("Выберите тип продукции.", "Ошибка заполнения", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            if (cmbMaterial.SelectedValue == null)
            {
                MessageBox.Show("Выберите основной материал.", "Ошибка заполнения", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // 2. ПРОВЕРКА ЦЕНЫ (должна быть числом >= 0)
            if (!decimal.TryParse(txtPrice.Text, out decimal price) || price < 0)
            {
                MessageBox.Show("Стоимость должна быть положительным числом (например, 1500.50).", "Ошибка ввода", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // 3. СОХРАНЕНИЕ В БД
            try
            {
                int typeId = (int)cmbProductType.SelectedValue;
                int materialId = (int)cmbMaterial.SelectedValue;

                dbHelper.SaveProduct(currentProductId, txtArticle.Text, txtName.Text, typeId, price, materialId);

                MessageBox.Show("Данные успешно сохранены!", "Успех", MessageBoxButtons.OK, MessageBoxIcon.Information);
                this.DialogResult = DialogResult.OK; // Говорим главной форме, что данные обновились
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при сохранении: " + ex.Message, "Ошибка БД", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}