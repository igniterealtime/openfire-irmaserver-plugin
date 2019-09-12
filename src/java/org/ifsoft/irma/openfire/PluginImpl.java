/*
 * Copyright (C) 2005-2010 Jive Software. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.ifsoft.irma.openfire;

import java.io.File;
import java.net.*;
import java.util.concurrent.*;
import java.util.*;
import java.util.function.*;
import java.util.stream.*;
import java.nio.file.*;

import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.openfire.http.HttpBindManager;
import org.jivesoftware.openfire.XMPPServer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.jivesoftware.util.JiveGlobals;
import org.jivesoftware.util.PropertyEventDispatcher;
import org.jivesoftware.util.PropertyEventListener;

import org.eclipse.jetty.apache.jsp.JettyJasperInitializer;
import org.eclipse.jetty.plus.annotation.ContainerInitializer;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.proxy.ProxyServlet;
import org.eclipse.jetty.servlets.*;
import org.eclipse.jetty.servlet.*;
import org.eclipse.jetty.webapp.WebAppContext;

import org.eclipse.jetty.util.security.*;
import org.eclipse.jetty.security.*;
import org.eclipse.jetty.security.authentication.*;

import org.apache.tomcat.InstanceManager;
import org.apache.tomcat.SimpleInstanceManager;

import java.lang.reflect.*;
import java.util.*;

import org.jitsi.util.OSUtils;
import de.mxro.process.*;


public class PluginImpl implements Plugin, PropertyEventListener, ProcessListener
{
    private static final Logger Log = LoggerFactory.getLogger(PluginImpl.class);
    private XProcess irmaThread = null;
    private String irmaExePath = null;
    private String irmaHomePath = null;

    private ServletContextHandler irmaContext;
    private ExecutorService executor;

    public void destroyPlugin()
    {
        PropertyEventDispatcher.removeListener(this);

        try {
            if (executor != null)   executor.shutdown();
            if (irmaThread != null) irmaThread.destory();

            HttpBindManager.getInstance().removeJettyHandler(irmaContext);
        }
        catch (Exception e) {
            Log.error("IRMA destroyPlugin", e);
        }
    }

    public void initializePlugin(final PluginManager manager, final File pluginDirectory)
    {
        PropertyEventDispatcher.addListener(this);
        checkNatives(pluginDirectory);

        boolean irmaEnabled = JiveGlobals.getBooleanProperty("irma.enabled", true);

        if (irmaExePath != null && irmaEnabled)
        {
            executor = Executors.newCachedThreadPool();

            String url = " --url " + JiveGlobals.getProperty("irma.external.url", getExternalUrl());
            String staticPath = " --static-path " + irmaHomePath + File.separator + "static";
            String schemesPath = " --schemes-path " + irmaHomePath + File.separator + "irma_configuration";

            irmaThread = Spawn.startProcess(irmaExePath + " server -vv " + url + staticPath + schemesPath, new File(irmaHomePath), this);

            irmaContext = new ServletContextHandler(null, "/irmaproxy", ServletContextHandler.SESSIONS);
            irmaContext.setClassLoader(this.getClass().getClassLoader());

            ServletHolder proxyServlet = new ServletHolder(ProxyServlet.Transparent.class);
            proxyServlet.setInitParameter("proxyTo", "http://127.0.0.1:8088");
            proxyServlet.setInitParameter("prefix", "/");
            irmaContext.addServlet(proxyServlet, "/*");

            HttpBindManager.getInstance().addJettyHandler(irmaContext);

            Log.info("IRMA enabled " + url + staticPath + schemesPath);

        } else {
            Log.info("IRMA disabled");
        }
    }

    public void sendLine(String command)
    {
        if (irmaThread != null) irmaThread.sendLine(command);
    }

    public String getExternalUrl()
    {
        return "http://" + JiveGlobals.getProperty("irma.ipaddr", getIpAddress()) + ":" + JiveGlobals.getProperty("httpbind.port.plain", "7070") + "/irmaproxy";
    }

    public String getIpAddress()
    {
        String ourHostname = XMPPServer.getInstance().getServerInfo().getHostname();
        String ourIpAddress = "127.0.0.1";

        try {
            ourIpAddress = InetAddress.getByName(ourHostname).getHostAddress();
        } catch (Exception e) {

        }

        return ourIpAddress;
    }

    public void onOutputLine(final String line)
    {
        Log.info("IRMA onOutputLine " + line);
    }

    public void onProcessQuit(int code)
    {
        Log.info("IRMA onProcessQuit " + code);
    }

    public void onOutputClosed() {
        Log.error("IRMA onOutputClosed");
    }

    public void onErrorLine(final String line)
    {
        Log.info(line);
    }

    public void onError(final Throwable t)
    {
        Log.error("IRMAThread error", t);
    }

    private void checkNatives(File pluginDirectory)
    {
        try
        {
            String suffix = null;

            if(OSUtils.IS_LINUX64)
            {
                suffix = "linux-64" + File.separator + "irma-master-linux-amd64";
            }
            else if(OSUtils.IS_WINDOWS64)
            {
                suffix = "win-64" + File.separator + "irma-master-windows-amd64.exe";
            }

            if (suffix != null)
            {
                irmaHomePath = pluginDirectory.getAbsolutePath() + File.separator + "classes";
                irmaExePath = irmaHomePath + File.separator + suffix;

                File file = new File(irmaExePath);
                file.setReadable(true, true);
                file.setWritable(true, true);
                file.setExecutable(true, true);

                Log.info("checkNatives irma executable path " + irmaExePath);

            } else {
                Log.error("checkNatives unknown OS " + pluginDirectory.getAbsolutePath());
            }
        }
        catch (Exception e)
        {
            Log.error("checkNatives error", e);
        }
    }

//-------------------------------------------------------
//
//
//
//-------------------------------------------------------


    public void propertySet(String property, Map params)
    {

    }

    public void propertyDeleted(String property, Map<String, Object> params)
    {

    }

    public void xmlPropertySet(String property, Map<String, Object> params) {

    }

    public void xmlPropertyDeleted(String property, Map<String, Object> params) {

    }

}
