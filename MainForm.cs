using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using Mebel_magaz.Data;
using Mebel_magaz.Models;

namespace Mebel_magaz
{
    public partial class MainForm : Form
    {
        private DbHelper dbHelper = new DbHelper();

        public MainForm()
        {
            InitializeComponent();
            // Загружаем данные при запуске формы
            LoadProducts();
        }

        // Метод для загрузки и отрисовки продукции
        private void LoadProducts()
        {
            try
            {
                // Очищаем панель перед загрузкой
                flowLayoutPanelProducts.Controls.Clear();

                // Получаем данные из БД
                List<Product> products = dbHelper.GetProducts();

                // Проходимся по каждому продукту и создаем для него карточку
                foreach (var product in products)
                {
                    Panel card = CreateProductCard(product);
                    flowLayoutPanelProducts.Controls.Add(card);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnAddProduct_Click(object sender, EventArgs e)
        {
            using (ProductEditForm editForm = new ProductEditForm()) // Вызов конструктора для добавления
            {
                if (editForm.ShowDialog() == DialogResult.OK)
                {
                    LoadProducts(); // Обновляем список после сохранения!
                }
            }
        }

        // Метод, который собирает визуальную карточку по макету
        private Panel CreateProductCard(Product product)
        {
            // Сама карточка (рамка)
            Panel card = new Panel
            {
                Width = flowLayoutPanelProducts.Width - 40,
                Height = 110,
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle,
                Margin = new Padding(10)
            };

            // Тип | Наименование продукта (верхняя строка, слева)
            Label lblTitle = new Label
            {
                Text = $"{product.ProductType} | {product.Name}",
                Font = new Font("Candara", 12, FontStyle.Bold),
                Location = new Point(10, 10),
                AutoSize = true
            };

            // Время изготовления (верхняя строка, справа)
            Label lblTime = new Label
            {
                Text = $"Время: {product.TotalTime} ч.",
                Font = new Font("Candara", 11, FontStyle.Bold),
                ForeColor = ColorTranslator.FromHtml("#355CBD"), // Акцентный цвет
                AutoSize = true,
                Location = new Point(card.Width - 120, 10),
                Anchor = AnchorStyles.Top | AnchorStyles.Right
            };

            // Артикул
            Label lblArticle = new Label
            {
                Text = $"Артикул: {product.Article}",
                Font = new Font("Candara", 10),
                Location = new Point(10, 35),
                AutoSize = true
            };

            // Минимальная стоимость
            Label lblPrice = new Label
            {
                Text = $"Мин. стоимость для партнера: {product.MinPrice:C2} руб.",
                Font = new Font("Candara", 10),
                Location = new Point(10, 55),
                AutoSize = true
            };

            // Основной материал
            Label lblMaterial = new Label
            {
                Text = $"Основной материал: {product.MainMaterial}",
                Font = new Font("Candara", 10),
                Location = new Point(10, 75),
                AutoSize = true
            };

            // Добавляем все элементы на карточку
            card.Controls.Add(lblTitle);
            card.Controls.Add(lblTime);
            card.Controls.Add(lblArticle);
            card.Controls.Add(lblPrice);
            card.Controls.Add(lblMaterial);

            // --- ЛОГИКА КЛИКА ДЛЯ РЕДАКТИРОВАНИЯ ---

            // Привязываем клик к самой карточке
            card.Click += (s, ev) => OpenEditForm(product.Id);

            // Привязываем клик ко всем элементам внутри карточки (метки)
            foreach (Control ctrl in card.Controls)
            {
                ctrl.Click += (s, ev) => OpenEditForm(product.Id);
                ctrl.Cursor = Cursors.Hand; // Курсор-рука
            }
            card.Cursor = Cursors.Hand; // Курсор-рука для самой карточки

            // Кнопка для просмотра цехов
            Button btnWorkshops = new Button
            {
                Text = "Цеха",
                Font = new Font("Candara", 9),
                BackColor = ColorTranslator.FromHtml("#D2DFFF"),
                Location = new Point(card.Width - 80, card.Height - 35),
                Size = new Size(70, 25),
                Anchor = AnchorStyles.Bottom | AnchorStyles.Right,
                Cursor = Cursors.Hand
            };

            btnWorkshops.Click += (s, ev) =>
            {
                using (WorkshopsForm wf = new WorkshopsForm(product.Id, product.Name))
                {
                    wf.ShowDialog();
                }
            };

            card.Controls.Add(btnWorkshops);

            return card;
        }

        // Отдельный метод для открытия формы редактирования
        private void OpenEditForm(int productId)
        {
            try
            {
                using (ProductEditForm editForm = new ProductEditForm(productId))
                {
                    if (editForm.ShowDialog() == DialogResult.OK)
                    {
                        LoadProducts();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при открытии формы: " + ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnAddProduct_Click_1(object sender, EventArgs e)
        {
            try
            {
                using (ProductEditForm editForm = new ProductEditForm())
                {
                    if (editForm.ShowDialog() == DialogResult.OK)
                    {
                        LoadProducts();
                    }
                }
            }
            catch (Exception ex)
            {
                // Если форма не открылась, мы хотя бы увидим почему
                MessageBox.Show("Ошибка при открытии формы: " + ex.Message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}