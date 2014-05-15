using System;
using System.Collections.Generic;
using System.EnterpriseServices.Internal;
using System.Linq;
using System.Web;
using Microsoft.Ajax.Utilities;
using NHibernate.Hql.Ast.ANTLR;

namespace Bookstore.Web.Models
{
    public struct ByOrderStatus
    {
        public ByOrderStatus(int count, int cost)
        {
            Cost = cost;
            Count = count;
        }

        public int Count;
        public int Cost;
    };

    public struct BookStat
    {
        public BookStat(string title, int count, int totalCost)
        {
            Title = title;
            Count = count;
            TotalCost = totalCost;
        }

        public string Title;
        public int Count;
        public int TotalCost;
    }

    public struct Bestseller
    {
        public Bestseller(string title, int count, int totalCost)
        {
            Title = title;
            Count = count;
            TotalCost = totalCost;
        }

        public string Title;
        public int Count;
        public int TotalCost;
    }

    public class StatModel
    {
        public ByOrderStatus InProcess;
        public ByOrderStatus Processed;
        public List<BookStat> Books;
        public int TotalCost;
        public Bestseller Bestseller;

        public StatModel()
        {
            Books = new List<BookStat>();
        }
    }
}