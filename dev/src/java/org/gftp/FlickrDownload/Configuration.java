/*
  FlickrDownload - Copyright(C) 2010 Brian Masney <masneyb@gmail.com>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://code.google.com/p/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
*/

package org.gftp.FlickrDownload;

import java.io.File;
import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.auth.Auth;
import com.aetrion.flickr.people.User;

public class Configuration {
	public Flickr flickr;
	public User authUser;
	public User photosUser;
	public File photosBaseDirectory;
	public File authDirectory;
	public File buddyIconFilename;
	public boolean downloadCollectionIcons = false;
	public boolean alwaysDownloadBuddyIcon = false;
	public boolean partialDownloads = false;
	public String addExtensionToUnknownFiles;
	public Auth auth;
	
	public Configuration(File photosBaseDirectory, File authDirectory, String userName) throws IOException, FlickrException, SAXException, ParserConfigurationException {
		this.flickr = Authentication.getFlickr();

		this.photosBaseDirectory = photosBaseDirectory;
		this.photosBaseDirectory.mkdirs();

		this.authDirectory = authDirectory != null ? authDirectory : photosBaseDirectory;
		this.authDirectory.mkdirs();

		this.auth = Authentication.getAuthToken(this.flickr, this.authDirectory, userName);
		this.authUser = this.flickr.getPeopleInterface().getInfo(this.auth.getUser().getId());
	}
}
