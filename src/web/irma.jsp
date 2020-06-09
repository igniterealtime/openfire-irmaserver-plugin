<%@ page import="java.util.*" %>
<%@ page import="org.ifsoft.irma.openfire.*" %>
<%@ page import="org.jivesoftware.openfire.*" %>
<%@ page import="org.jivesoftware.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="admin" prefix="admin" %>
<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager" />
<% webManager.init(request, response, session, application, out); %>
<%
    boolean update = request.getParameter("update") != null;

    // Get handle on the plugin
    PluginImpl plugin = (PluginImpl) XMPPServer.getInstance().getPluginManager().getPlugin("irmaserver");

    Cookie csrfCookie = CookieUtils.getCookie(request, "csrf");
    String csrfParam = ParamUtils.getParameter(request, "csrf");
    Map<String,String> errors = new HashMap<>();

    if (update && (csrfCookie == null || csrfParam == null || !csrfCookie.getValue().equals(csrfParam))) {
        update = false;
        errors.put("csrf", "CSRF Failure - please try again.");
    }

    csrfParam = StringUtils.randomString(16);
    CookieUtils.setCookie(request, response, "csrf", csrfParam, -1);
    pageContext.setAttribute("csrf", csrfParam);

    if (errors.isEmpty() && update)
    {    
        String externalUrl = request.getParameter("externalUrl");     
        JiveGlobals.setProperty("irma.external.url", externalUrl);     
        
        String ipaddr = request.getParameter("ipaddr");     
        JiveGlobals.setProperty("irma.ipaddr", ipaddr);   
        
        String irmaEnabled = request.getParameter("irmaEnabled");
        JiveGlobals.setProperty("irma.enabled", (irmaEnabled != null && irmaEnabled.equals("on")) ? "true": "false");

        // Log the event
        webManager.logEvent("updated IRMA server settings", "externalURL = "+externalUrl+"\nipaddr = "+ipaddr+"\nirmaEnabled = "+irmaEnabled);
        response.sendRedirect("irma.jsp?success=true");
        return;
    }

    pageContext.setAttribute("errors", errors);
    pageContext.setAttribute("isEnabled", JiveGlobals.getProperty("irma.enabled", "true"));
    pageContext.setAttribute("externalUrl", JiveGlobals.getProperty("irma.external.url", plugin.getExternalUrl()) );
    pageContext.setAttribute("ipAddress", JiveGlobals.getProperty("irma.ipaddr", plugin.getIpAddress()));
%>
<html>
<head>
   <title><fmt:message key="plugin.title.description" /></title>

   <meta name="pageID" content="irma-settings"/>
</head>
<body>

<c:choose>
    <c:when test="${not empty errors}">
        <c:forEach var="err" items="${errors}">
            <admin:infobox type="error">
                <c:choose>
                    <c:when test="${err.key eq 'csrf'}"><fmt:message key="global.csrf.failed" /></c:when>
                    <c:otherwise>
                        <c:if test="${not empty err.value}">
                            <fmt:message key="admin.error"/>: <c:out value="${err.value}"/>
                        </c:if>
                        (<c:out value="${err.key}"/>)
                    </c:otherwise>
                </c:choose>
            </admin:infobox>
        </c:forEach>
    </c:when>
    <c:when test="${param.success}">
        <admin:infobox type="success">
            <fmt:message key="config.page.configuration.settings_updated" />
        </admin:infobox>
    </c:when>
</c:choose>

<div class="jive-table">
<form action="irma.jsp" method="post">
    <input type="hidden" name="csrf" value="${csrf}">
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
                    <input type="checkbox" name="irmaEnabled" ${isEnabled ? "checked" :""}>
                    <fmt:message key="config.page.configuration.enabled" />       
                </td>  
            </tr>
            <tr>
                <td align="left" width="150">
                    <fmt:message key="config.page.configuration.external.url"/>
                </td>
                <td><input type="text" size="50" maxlength="100" name="externalUrl"
                       value="<c:out value="${externalUrl}"/>">
                </td>
            </tr>             
            <tr>
                <td align="left" width="150">
                    <fmt:message key="config.page.configuration.ipaddr"/>
                </td>
                <td><input type="text" size="50" maxlength="100" name="ipaddr"
                       value="<c:out value="${ipAddress}"/>">
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
