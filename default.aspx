<%@ language="C#" Debug="true" validateRequest="false" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Xml.Linq" %>
<script runat="server">
    string folder = "";
    string rules = "";
    bool webConfigExist = false;   
    
    private void CreateWebConfig() {
         var webConfig = new FileInfo(Path.Combine(folder, "web.config")).AppendText();
         webConfig.WriteLine("<?xml version=\"1.0\" ?>");
         webConfig.WriteLine("<configuration>");
         webConfig.WriteLine("  <system.webServer>");
         webConfig.WriteLine("      <rewrite>");
         webConfig.WriteLine("          <rules>");   
         webConfig.WriteLine("              <rule name=\"ProxyExample\" stopProcessing=\"true\">");
         webConfig.WriteLine("                  <match url=\"^ch9/?(.*)\" />");
         webConfig.WriteLine("                  <action type=\"Rewrite\" url=\"http://channel9.msdn.com/{R:1}\" />");
         webConfig.WriteLine("              </rule>");
         webConfig.WriteLine("          </rules>");
         webConfig.WriteLine("      </rewrite>");
         webConfig.WriteLine("  </system.webServer>");
         webConfig.WriteLine("</configuration>");
         webConfig.Close();
    }
    
    private string GetRewriteRules()
    {
       string rulesXml = "";
       XDocument xmlDoc;
       using (StreamReader read = new FileInfo(Path.Combine(folder,"Web.config")).OpenText()){
          xmlDoc = XDocument.Load(read);
       }
       IEnumerable<XElement> rules = from rule in xmlDoc.Descendants("rewrite") select rule;
       foreach (XElement rule in rules)
       {
          rulesXml = string.Format("{0}\n{1}", rulesXml, rule);
       }
       return rulesXml;
    }
      
    private void WriteRewriteRules(string rules){
       string filePath = Path.Combine(folder,"Web.config");
       XDocument xmlDoc;
       using (StreamReader read = new FileInfo(filePath).OpenText()){
          xmlDoc = XDocument.Load(read);
       }
       var rulesElement = xmlDoc.Descendants("rewrite").SingleOrDefault();
       if (rulesElement != null){
           //Refactor!!
           rules = rules.Replace("<rewrite>","");
           rules = rules.Replace("</rewrite>","");
           rulesElement.ReplaceNodes(XElement.Parse(rules));
           xmlDoc.Save(filePath);
           return; 
       }
         
       rulesElement = xmlDoc.Descendants("system.webServer").SingleOrDefault();
       if (rulesElement != null){
           rulesElement.Add(XElement.Parse(rules));
           xmlDoc.Save(filePath);
           return;
       }
              
       rulesElement = xmlDoc.Descendants("configuration").SingleOrDefault(); 
       rules = string.Format("<system.webServer>{0}</system.webServer>", rules);
       rulesElement.Add(XElement.Parse(rules));
       xmlDoc.Save(filePath);
    }

    protected void Page_Load(object sender, EventArgs e) {  
        folder = Environment.ExpandEnvironmentVariables(@"%HOME%\site\wwwroot");
        webConfigExist = (Directory.GetFiles(folder, "web.config", SearchOption.TopDirectoryOnly).Length > 0);      
        if (!webConfigExist) {
           CreateWebConfig();
        }
        
        string newRules = Request.Form["rulesBox"];
        if(!string.IsNullOrEmpty(newRules)){
          WriteRewriteRules(newRules);
        }
        rules = GetRewriteRules();
        if (string.IsNullOrEmpty(rules)) {
        }
    }
</script>
<html>
    <head>
        <title>Reverse Proxy Rule editor</title>
        <script src="http://cdn.siteextensions.net/lib/siteExtensionUpdater/siteExtensionUpdater.1.0.0.min.js"></script>
        <script>
            function CreateExample(){
                document.getElementById('rulesBox').value = "<rewrite>\n\t<rules>\n\t\t<rule name=\"ProxyExample\" stopProcessing=\"true\">\n\t\t\t<match url=\"^ch9/?(.*)\" />\n\t\t\t<action type=\"Rewrite\" url=\"http://channel9.msdn.com/{R:1}\" />\n\t\t</rule>\n\t</rules>\n</rewrite>";
            }
        </script>
    </head>
    <body>
        <h1>Reverse Proxy Settings</h1>More examples can be found
        <a href="https://github.com/EelcoKoster/ReverseProxySiteExtension/blob/master/README.md"
        target="_new">here</a>
        <br/>
        <br/>
        <a href="javascript:CreateExample();">Create Example</a>
        <form method="Post">
            <textarea name="rulesBox" id="rulesBox" rows="25" cols="120"><%=rules %></textarea>
            <br/>
            <input type="submit" value="Save to web.config">
        </form>
    </body>
</html>