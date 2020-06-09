<%@ page import="java.util.*" %>
<%@ page import="org.ifsoft.irma.openfire.*" %>
<%@ page import="org.jivesoftware.openfire.*" %>
<%@ page import="org.jivesoftware.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%

    boolean update = request.getParameter("update") != null;
    String errorMessage = null;

    // Get handle on the plugin
    PluginImpl plugin = (PluginImpl) XMPPServer.getInstance().getPluginManager().getPlugin("irmaserver");

    if (update)
    {    
        String externalUrl = request.getParameter("externalUrl");     
        JiveGlobals.setProperty("irma.external.url", externalUrl);     
        
        String ipaddr = request.getParameter("ipaddr");     
        JiveGlobals.setProperty("irma.ipaddr", ipaddr);   
        
        String irmaEnabled = request.getParameter("irmaEnabled");
        JiveGlobals.setProperty("irma.enabled", (irmaEnabled != null && irmaEnabled.equals("on")) ? "true": "false");        
    }

%>
<html>
<head>
   <title><fmt:message key="plugin.title.description" /></title>

   <meta name="pageID" content="irma-settings"/>
</head>
<body>
<% if (errorMessage != null) { %>
<div class="error">
    <%= errorMessage%>
</div>
<br/>
<% } %>

<div class="jive-table">
<form action="irma.jsp" method="post">
    <p>
        <table class="jive-table" cellpadding="0" cellspacing="0" border="0" width="100%">
            <thead> 
            <tr>
                <th colspan="2"><fmt:message key="config.page.settings.description"/></th>
            </tr>
            </thead>
            <tbody>  
            <tr>
                <td nowrap  colspan="2">
                    <input type="checkbox" name="irmaEnabled"<%= (JiveGlobals.getProperty("irma.enabled", "true").equals("true")) ? " checked" : "" %>>
                    <fmt:message key="config.page.configuration.enabled" />       
                </td>  
            </tr>
            <tr>
                <td align="left" width="150">
                    <fmt:message key="config.page.configuration.external.url"/>
                </td>
                <td><input type="text" size="50" maxlength="100" name="externalUrl"
                       value="<%= JiveGlobals.getProperty("irma.external.url", plugin.getExternalUrl()) %>">
                </td>
            </tr>             
            <tr>
                <td align="left" width="150">
                    <fmt:message key="config.page.configuration.ipaddr"/>
                </td>
                <td><input type="text" size="50" maxlength="100" name="ipaddr"
                       value="<%= JiveGlobals.getProperty("irma.ipaddr", plugin.getIpAddress()) %>">
                </td>                               
            </tr>             
            </tbody>
        </table>
    </p>
   <p>
        <table class="jive-table" cellpadding="0" cellspacing="0" border="0" width="100%">
            <thead> 
            <tr>
                <th colspan="2"><fmt:message key="config.page.configuration.save.title"/></th>
            </tr>
            </thead>
            <tbody>         
            <tr>
                <th colspan="2"><input type="submit" name="update" value="<fmt:message key="config.page.configuration.submit" />"><fmt:message key="config.page.configuration.restart.warning"/></th>
            </tr>       
            </tbody>            
        </table> 
    </p>
</form>
</div>
</body>
</html>
