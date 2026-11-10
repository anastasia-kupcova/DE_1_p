using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Mebel_magaz.Models
{
    public class Product
    {
        public int Id { get; set; }
        public string Article { get; set; }
        public string Name { get; set; }
        public string ProductType { get; set; }
        public decimal MinPrice { get; set; }
        public string MainMaterial { get; set; }
        public int TotalTime { get; set; } // Время изготовления (сумма по цехам)
    }
}
