using System;
using System.IO;
using System.util;
using iTextSharp.text;
using iTextSharp.text.html;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;

namespace Bookstore.Services
{
    public static class DocumentHelper
    {
        /// <summary>
        /// HTMLs to PDF.
        /// </summary>
        public static Byte[] HtmlToPdf(String html, Boolean isWithoughtPadding = false)
        {
            FontFactory.Register("c:/Windows/Fonts/arial.ttf");
            var msOutput = new MemoryStream();
            TextReader reader = new StringReader(html);
            var document = isWithoughtPadding ? 
                new Document(PageSize.A4, 0, 0, 0, 0) : 
                new Document(PageSize.A4, 20, 20, 20, 20);
            
            PdfWriter.GetInstance(document, msOutput);

            var style = new StyleSheet();
            style.LoadStyle("width8", iTextSharp.text.html.HtmlTags.WIDTH, "8%");
            style.LoadStyle("width10", iTextSharp.text.html.HtmlTags.WIDTH, "10%");
            style.LoadStyle("width12", iTextSharp.text.html.HtmlTags.WIDTH, "12%");
            style.LoadStyle("width17", iTextSharp.text.html.HtmlTags.WIDTH, "17%");
            style.LoadStyle("width20", iTextSharp.text.html.HtmlTags.WIDTH, "20%");
            style.LoadStyle("vertAlignTop", iTextSharp.text.html.HtmlTags.VERTICALALIGN, "top"); 
            style.LoadTagStyle(HtmlTags.BODY, HtmlTags.FACE, "Arial Unicode MS");

            var worker = new HTMLWorker(document);
            worker.SetStyleSheet(style);

            document.Open();
            worker.StartDocument();
            worker.Parse(reader);
            worker.EndDocument();
            worker.Close();
            document.Close();
            
            var result = msOutput.ToArray();
            msOutput.Close();
            return result;
        }
    }
}
