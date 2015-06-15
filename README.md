Reverse Proxy WebApp Extension
========================

This extension configures your Azure WebApp to act as a reverse proxy and forward web request to other URL’s based on the incoming request URL path. More details about IIS and Reverse Proxy can be found [here](http://www.iis.net/learn/extensions/url-rewrite-module/reverse-proxy-with-url-rewrite-v2-and-application-request-routing).

The extension enables the proxy in the applicationhost.config file of your WebApp. You can configure the proxy by adding rewrite rules in your web.config file.

To help you create the rewrite rules I added 3 examples which also demonstrates the use cases for this extension.

### Example 1: Integrate an external url in your WebApp
```
<rewrite>
  <rules>
    <rule name="ScriptProxy" stopProcessing="true">
      <match url="^script/?(.*)" />
      <action type="Rewrite" url="http://scripts.azurewebsites.net/customscripts/{R:1}" />
    </rule>
  </rules>
 </rewrite>
```
This rule must be placed in the web.config file within the &lt;system.webServer&gt; tag.
With this rule you create a virtual folder in your site, and the content will be pulled from the external site.
The client will not be redirected and thinks the content is from your site.
This comes in handy to overcome CORS problems with javascript files from different domains or if you would like to combine multiple sites under one domain.  
 
### Example 2: Use a blob storage account for your static content
```
<rewrite>
   <rules>
      <rule name="Add index.html to root">
         <match url="^$" />
         <conditions>
            <add input="{REQUEST_URI}" pattern="^/" />
         </conditions>
         <action type="Rewrite" url="/index.htm" />
      </rule>
      <rule name="Rewrite urls without a dot after the last slash" stopProcessing="true">
         <match url="(.*)/([^.]+$)" />
         <action type="Redirect" url="/{R:0}/index.htm" />
      </rule>
      <rule name="Add index.html to folders" stopProcessing="true">
         <match url="^/?(.*)/$" />
         <action type="Rewrite" url="http://[storageaccountname].blob.core.windows.net/content/{R:1}/index.htm" />
      </rule>
      <rule name="Proxy content" stopProcessing="true">
         <match url="^/?(.*)" />
         <action type="Rewrite" url="http://[storageaccountname].blob.core.windows.net/content/{R:1}" />
      </rule>
   </rules>
</rewrite>
```
Because (blob) storage accounts don't have the concept of default documents it's very impractical to use a storage account for your static websites.
With the above example all requests to your WebApp will be forwarded to a storage account. 
in this example it is forwarded to the "content" container of your storage account, and "index.htm" is the default page it will search for if you don't have a file at the end of your URL.

With this feature you can but a terabyte of static content behind your WebApp and still use a cheap price plan.
   
### Example 3: Integrate an external site in your WebApp
```
<rewrite>
  <rules>
    <rule name="BlogProxy" stopProcessing="true">
      <match url="^blog/?(.*)" />
      <action type="Rewrite" url="http://eelco.azurewebsites.net/{R:1}" />
      <serverVariables>
        <set name="HTTP_ACCEPT_ENCODING" value="" />
      </serverVariables>
    </rule>
  </rules>
  <outboundRules>
    <rule name="RewriteRelativePaths" preCondition="ResponseIsHtml">
      <match filterByTags="A, Img" pattern="^/(.*)" />
      <action type="Rewrite" value="/blog/{R:1}" />
    </rule>
    <preConditions>
      <preCondition name="ResponseIsHtml">
        <add input="{RESPONSE_CONTENT_TYPE}" pattern="^text/html" />
      </preCondition>
    </preConditions>
  </outboundRules>
</rewrite>
```
This example puts my weblog in the /blog/ folder of your WebApp :-) (it's just an example!)
Next to the rule to forward all traffic in the blog folder to my site, I also but in an outbound rule to transform the output of my site. 
The outbound rule will first check if the output file has the content type "text/html" and then will append a "/blog/" before all relative paths in the A and IMG htmltags.

WARNING: For outbound rules to work you have to disable the output encoding of the site you're trying to proxy. In this example I do this by clearing the "HTTP_ACCEPT_ENCODING" header. This will have an impact on the performance and cost for outbound traffic.
