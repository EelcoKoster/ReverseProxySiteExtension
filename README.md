Reverse Proxy WebApp Extension
========================

This extension configures your Azure WebApp to act as a reverse proxy and forward web request to other URL’s based on the incoming request URL path. More details about IIS and Reverse Proxy can be found [here](http://www.iis.net/learn/extensions/url-rewrite-module/reverse-proxy-with-url-rewrite-v2-and-application-request-routing).

The extension enables the proxy in the applicationhost.config file of your WebApp. You can configure the proxy by adding rewrite rules in your web.config file.

To help you create the rewrite rules I added 2 examples which also demonstrates the use cases for this extension.

Example 1: Integrate an external site in your WebApp

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
    <rule name="test" stopProcessing="true">
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

Example 2: Use a blob storage account for your static content


