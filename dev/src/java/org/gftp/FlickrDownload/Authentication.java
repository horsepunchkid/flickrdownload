/*
  FlickrDownload - Copyright(C) 2010 Brian Masney <masneyb@onstation.org>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://www.onstation.org/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
*/

package org.gftp.FlickrDownload;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.log4j.Logger;
import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.REST;
import com.aetrion.flickr.RequestContext;
import com.aetrion.flickr.Response;
import com.aetrion.flickr.auth.Auth;
import com.aetrion.flickr.auth.Permission;
import com.aetrion.flickr.util.AuthStore;
import com.aetrion.flickr.util.FileAuthStore;

public class Authentication {
	public static Flickr getFlickr() throws ParserConfigurationException {
		return new Flickr("16c1a6a31f28e670500d02f6b13935b1", "0fa4d39da5eab415", new RESTRetryTransport());
	}
	
	public static Auth getAuthToken(Flickr flickr, File authDirectory, String username) throws IOException, SAXException, FlickrException {
		AuthStore authStore = new FileAuthStore(authDirectory);
		Auth auth = authStore.retrieve(flickr.getPeopleInterface().findByUsername(username).getId());
		if (auth != null) {
			RequestContext.getRequestContext().setAuth(auth);
			return auth;
		}

		String frob = flickr.getAuthInterface().getFrob();
		URL authUrl = flickr.getAuthInterface().buildAuthenticationUrl(Permission.READ, frob);
		System.out.println("Please visit the following URL:");
		System.out.println();
		System.out.println(authUrl.toExternalForm());
		System.out.println();
		System.out.println("Press enter once the application has been authorized.");
		System.in.read();

		Auth token = flickr.getAuthInterface().getToken(frob);
		authStore.store(token);
		RequestContext.getRequestContext().setAuth(auth);
		return token;
	}

	protected static class RESTRetryTransport extends REST {
		public RESTRetryTransport() throws ParserConfigurationException {
			super();
		}

		@Override
	    public Response get(String path, List parameters) throws IOException, SAXException {
			while (true) {
				try {
					return super.get(path, parameters);
				}
				catch (IOException e) {
					Logger.getLogger(getClass()).warn(String.format("Get operation failed, retrying: %s", e.getMessage()), e);
					try {
						Thread.sleep(4000);
					}
					catch (InterruptedException ie) {
						// NOOP
					}
				}
			}
		}
		
		@Override
	    public Response post(String path, List parameters, boolean multipart) throws IOException, SAXException {
			while (true) {
				try {
					return super.post(path, parameters, multipart);
				}
				catch (IOException e) {
					Logger.getLogger(getClass()).warn(String.format("Post operation failed, retrying: %s", e.getMessage()), e);
					try {
						Thread.sleep(4000);
					}
					catch (InterruptedException ie) {
						// NOOP
					}
				}
			}
		}
	}
}
