using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;
using Bookstore.Services;
using Bookstore.Web.Models;

namespace Bookstore.Web.Controllers
{
    public class HomeController : BaseController
    {
        #region Connection
        private const string connectionString = @"Data Source=.\SQLExpress;Initial Catalog=Bookstore;Integrated Security=True;MultipleActiveResultSets=True";
        #endregion

        [Route("", Name = "WebsiteHome")]
        public ActionResult Index()
        {
            return View();
        }

        [Route("search", Name = "SearchPage")]
        [HttpGet]
        public ActionResult Search()
        {
            return View("Search");
        }

        [Route("search", Name = "SearchBook")]
        [HttpPost]
        public ViewResult Search(FormCollection collection)
        {
            const string @select = "select Book.Id, Creation.Title, Creation.OriginalTitle from Bookstore.Catalog.Book " +
                                   "join Bookstore.Catalog.Creation " +
                                   "on Bookstore.Catalog.Book.CreationId = Bookstore.Catalog.Creation.Id";

            var searchString = collection["search"];

            var books = new List<Dictionary<string, string>>();

            if (searchString.Length > 0)
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    using (var cmd = new SqlCommand(select, conn))
                    {
                        conn.Open();
                        using (var sdr = cmd.ExecuteReader())
                        {

                            while (sdr.Read())
                            {
                                var words =
                                    sdr[1].ToString().ToLower().Split(new[] {" "}, StringSplitOptions.RemoveEmptyEntries).ToList();
                                words.AddRange(
                                    sdr[2].ToString().ToLower().Split(new[] { " " }, StringSplitOptions.RemoveEmptyEntries).ToList());

                                if (words.Any(x => x.StartsWith(searchString.ToLower())))
                                {
                                    books.Add(new Dictionary<string, string>
                                              {
                                                  {"Id", sdr[0].ToString()},
                                                  {"Название", sdr[1].ToString()},
                                                  {"Оригинальное название", sdr[2].ToString()}
                                              });
                                }


                            }
                        }
                        conn.Close();
                    }
                }
            }

            ViewBag.Books = books.Count == 0 ? null : books;
            return View("Search");
        }

        [Route("export")]
        public FileResult Export()
        {
            const string select =
                "select * from Bookstore.Catalog.Book " +
                "join Bookstore.Catalog.Creation " +
                "on Bookstore.Catalog.Book.CreationId = Bookstore.Catalog.Creation.Id " +
                "join Bookstore.Catalog.Publisher " +
                "on Bookstore.Catalog.Book.PublisherId = Bookstore.Catalog.Publisher.Id";

            const string delimetr = ";";
            var csv = new StringBuilder();
            var headers = new[]
                {
                    "BookId",
                    "LanguageId",
                    "CreationId",
                    "PublisherId",
                    "BookTypeId",
                    "PlacementDate",
                    "Rating",
                    "Edition",
                    "PublicationPlace",
                    "PublishedDate",
                    "PublisherSeries",
                    "LowerAgeLimit",
                    "CoverTypeId",
                    "IsIllustrated",
                    "Pages",
                    "Weight",
                    "Description",

                    "Title",
                    "OriginalTitle",
                    "Annotation",

                    "PublisherName"
                };

            csv.AppendLine(headers.Where(header => header != headers.Last()).
                Aggregate("", (current, header) => current + (header + delimetr)) + headers.Last());

            using (var conn = new SqlConnection(connectionString))
            {
                using (var cmd = new SqlCommand(select, conn))
                {
                    conn.Open();
                    using (var sdr = cmd.ExecuteReader())
                    {

                        while (sdr.Read())
                        {
                            for (var i = 0; i <= 16; i++)
                                csv.Append(sdr[i] + delimetr);
                            for (var i = 20; i <= 21; i++)
                                csv.Append(sdr[i] + delimetr);
                            csv.Append(sdr[23] + delimetr);
                            csv.Append(sdr[27] + delimetr);
                            csv.AppendLine();
                        }
                    }
                    conn.Close();
                }
            }

            var fileBytes = Encoding.Default.GetBytes(csv.ToString());
            var fileName = "export " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString() + ".csv";
            return File(fileBytes, System.Net.Mime.MediaTypeNames.Application.Octet, fileName);
        }

        [Route("import")]
        [HttpGet]
        public ActionResult Import()
        {
            return View("Import");
        }

        [Route("import")]
        [HttpPost]
        public ActionResult ImportBooks(HttpPostedFileBase file)
        {
            const string maxPublisherId = "SELECT MAX(Id) FROM Bookstore.Catalog.Publisher";
            const string maxCreationId = "SELECT MAX(Id) FROM Bookstore.Catalog.Creation";
            const string maxBookId = "SELECT MAX(Id) FROM Bookstore.Catalog.Book";

            try
            {
                if (file != null && file.ContentLength > 0)
                {
                    var br = new BinaryReader(file.InputStream);
                    var binData = br.ReadBytes((int)file.InputStream.Length);
                    var rows = Encoding.Default.GetString(binData).Split(new[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList();
                    rows.Remove(rows.First());


                    using (var conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        var bookId = Convert.ToInt32(new SqlCommand(maxBookId, conn).ExecuteScalar());
                        var publisherId = Convert.ToInt32(new SqlCommand(maxPublisherId, conn).ExecuteScalar());
                        var creationId = Convert.ToInt32(new SqlCommand(maxCreationId, conn).ExecuteScalar());

                        foreach (var fields in rows.Select(row => row.Split(new[] { ';' }, StringSplitOptions.None)))
                        {
                            int count;

                            #region Publisher
                            var tempCmd =
                                new SqlCommand(
                                    String.Format("select count(*) from Bookstore.Catalog.Publisher where Name = @Name"),
                                    conn);
                            tempCmd.Parameters.AddWithValue("@Name", fields[1]);
                            count = Convert.ToInt32(tempCmd.ExecuteScalar());

                            if (count == 0)
                            {
                                publisherId++;
                                tempCmd =
                                    new SqlCommand("insert into Bookstore.Catalog.Publisher (Id, Name) values (@Id, @Name)", conn);
                                tempCmd.Parameters.AddWithValue("@Id", publisherId);
                                tempCmd.Parameters.AddWithValue("@Name", fields[1]);
                                tempCmd.ExecuteScalar();
                            }
                            #endregion

                            #region Creation
                            creationId++;
                            tempCmd =
                                new SqlCommand("insert into Bookstore.Catalog.Creation " +
                                               "(Id, LanguageId, Title, OriginalTitle, Annotation) " +
                                               "values (@Id, @LanguageId, @Title, @OriginalTitle, @Annotation)", conn);
                            tempCmd.Parameters.AddWithValue("@Id", creationId);
                            tempCmd.Parameters.AddWithValue("@LanguageId", fields[0]);
                            tempCmd.Parameters.AddWithValue("@Title", fields[6]);
                            tempCmd.Parameters.AddWithValue("@OriginalTitle", fields[7]);
                            tempCmd.Parameters.AddWithValue("@Annotation", fields[8]);
                            tempCmd.ExecuteScalar();
                            #endregion

                            #region Book
                            tempCmd =
                                new SqlCommand(
                                    String.Format("select Id from Bookstore.Catalog.Publisher where Name = @Name"),
                                    conn);
                            tempCmd.Parameters.AddWithValue("@Name", fields[1]);
                            var bookPublisherId = Convert.ToInt32(tempCmd.ExecuteScalar());

                            bookId++;
                            tempCmd =
                                new SqlCommand("insert into Bookstore.Catalog.Book " +
                                               "(Id, LanguageId, CreationId, PublisherId, BookTypeId," +
                                               "PlacementDate, Rating, Edition, PublicationPlace," +
                                               "PublishedDate, PublisherSeries, LowerAgeLimit," +
                                               "CoverTypeId, IsIllustrated, Pages, Weight, Description) "+

                                               "values (@Id, @LanguageId, @CreationId, @PublisherId, @BookTypeId," +
                                               "@PlacementDate, @Rating, @Edition, @PublicationPlace," +
                                               "@PublishedDate, @PublisherSeries, @LowerAgeLimit," +
                                               "@CoverTypeId, @IsIllustrated, @Pages, @Weight, @Description)", conn);
                            tempCmd.Parameters.AddWithValue("@Id", creationId);
                            tempCmd.Parameters.AddWithValue("@LanguageId", fields[0]);
                            tempCmd.Parameters.AddWithValue("@CreationId", creationId);
                            tempCmd.Parameters.AddWithValue("@PublisherId", bookPublisherId);
                            tempCmd.Parameters.AddWithValue("@BookTypeId", fields[9]);
                            tempCmd.Parameters.AddWithValue("@PlacementDate", DateTime.Now);
                            tempCmd.Parameters.AddWithValue("@Rating", 0);
                            tempCmd.Parameters.AddWithValue("@Edition", fields[10]);
                            tempCmd.Parameters.AddWithValue("@PublicationPlace", fields[4]);
                            tempCmd.Parameters.AddWithValue("@PublishedDate", 
                                new DateTime(Convert.ToInt32(fields[2]), 1, 1));
                            tempCmd.Parameters.AddWithValue("@PublisherSeries", fields[3]);
                            tempCmd.Parameters.AddWithValue("@LowerAgeLimit", fields[11]);
                            tempCmd.Parameters.AddWithValue("@CoverTypeId", fields[12]);
                            tempCmd.Parameters.AddWithValue("@IsIllustrated", fields[13]);
                            tempCmd.Parameters.AddWithValue("@Pages", fields[14]);
                            tempCmd.Parameters.AddWithValue("@Weight", fields[15]);
                            tempCmd.Parameters.AddWithValue("@Description", fields[5]);
                            tempCmd.ExecuteScalar();
                            #endregion
                        }
                        conn.Close();
                    }

                    return Redirect("admin/Books/list.aspx");
                }

                return View("Import");
            }
            catch (Exception)
            {
                return View("Import");
            }
        }
       
        [Route("statistic")]
        [HttpGet]
        public FileResult GenerateStatistic()
        {
            const string statByStatus =
                    "SELECT COUNT(*), SUM(OrderTotal) FROM [Bookstore].[Shop].[Order] WHERE OrderStatusId = @Id";
            const string totalAmount = "SELECT SUM(OrderTotal) FROM [Bookstore].[Shop].[Order]";
            const string bestseller = "SELECT TOP 1 creation.Title, Sum(Quantity), ProductId  " +
                                       "FROM Bookstore.Shop.OrderItem as orderItem " +
                                       "JOIN Bookstore.Catalog.Creation as creation ON creation.Id = ProductId " +
                                       "GROUP BY orderItem.ProductId, creation.Title " +
                                       "ORDER BY Sum(Quantity) DESC";

            const string sellingStat = "SELECT T.Title, Sum(T.TotalCount), Sum(T.TotalCost)  FROM " +
                                       "(SELECT creation.Title, " +
                                       "Sum(Quantity) as TotalCount, Quantity * UnitPrice as TotalCost " +
                                       "FROM Bookstore.Shop.OrderItem as orderItem " +
                                       "JOIN Bookstore.Catalog.Creation as creation ON creation.Id = ProductId " +
                                       "GROUP BY orderItem.ProductId, creation.Title, Quantity, UnitPrice) as T " +
                                       "GROUP BY T.Title " +
                                       "ORDER BY Sum(T.TotalCount) DESC";

            var statistic = new StatModel();
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                #region Total Cost
                var tempCmd = new SqlCommand(totalAmount, conn);
                using (var sdr = tempCmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        statistic.TotalCost = Convert.ToInt32(sdr[0]);
                    }
                }
                #endregion

                #region Order in process
                tempCmd = new SqlCommand(statByStatus, conn);
                tempCmd.Parameters.AddWithValue("@Id", 1);
                using (var sdr = tempCmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        statistic.InProcess = new ByOrderStatus(Convert.ToInt32(sdr[0]), Convert.ToInt32(sdr[1]));
                    }
                }
                #endregion

                #region Order in process
                tempCmd = new SqlCommand(statByStatus, conn);
                tempCmd.Parameters.AddWithValue("@Id", 2);
                using (var sdr = tempCmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        statistic.Processed = new ByOrderStatus(Convert.ToInt32(sdr[0]), Convert.ToInt32(sdr[1]));
                    }
                }
                #endregion

                #region Books statistic
                tempCmd = new SqlCommand(sellingStat, conn);
                using (var sdr = tempCmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        statistic.Books.Add(
                            new BookStat(sdr[0].ToString(), Convert.ToInt32(sdr[1]), Convert.ToInt32(sdr[2])));
                    }
                }
                #endregion

                #region Bestseller
                tempCmd = new SqlCommand(bestseller, conn);
                using (var sdr = tempCmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        statistic.Bestseller = 
                            new Bestseller(sdr[0].ToString(), Convert.ToInt32(sdr[1]), Convert.ToInt32(sdr[2]));
                    }
                }
                #endregion
                conn.Close();
            }

            var fileName = "statistic " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString() + ".pdf";

            var html = HttpUtility.HtmlDecode(RenderPartialViewToString("Statistic", statistic));
            var pdfBytes = DocumentHelper.HtmlToPdf(html);

            return File(pdfBytes, System.Net.Mime.MediaTypeNames.Application.Octet, fileName);
        }

        protected String RenderPartialViewToString(String viewName, Object model)
        {
            if (String.IsNullOrEmpty(viewName))
            {
                viewName = ControllerContext.RouteData.GetRequiredString("action");
            }

            ViewData.Model = model;

            using (var sw = new StringWriter())
            {
                var viewResult = ViewEngines.Engines.FindPartialView(ControllerContext, viewName);
                var viewContext = new ViewContext(ControllerContext, viewResult.View, ViewData, TempData, sw);
                viewResult.View.Render(viewContext, sw);

                return sw.GetStringBuilder().ToString();
            }
        }
    }
}