/*****************************************************************************/
/*  FlickrDownload                                                           */
/*  Copyright (C) 2007 Brian Masney <masneyb@gftp.org>                       */
/*                                                                           */
/*  This program is free software; you can redistribute it and/or modify     */
/*  it under the terms of the GNU General Public License as published by     */
/*  the Free Software Foundation; either version 3 of the License, or        */
/*  (at your option) any later version.                                      */
/*                                                                           */
/*  This program is distributed in the hope that it will be useful,          */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            */
/*  GNU General Public License for more details.                             */
/*                                                                           */
/*  You should have received a copy of the GNU General Public License        */
/*  along with this program. If not, see <http://www.gnu.org/licenses/>.     */
/*****************************************************************************/

using System.Configuration;

namespace org.gftp
{

static class FlickrDownload
  {
    static FlickrNet.Flickr flickr = null;
    static bool xsltModeOnly = false;
    static bool downloadPhotos = true;
    static bool downloadPhotoPrivacy = true;

    static string xsltBasePath;
    static string flickrUsername;
    static string outputPath;
    static string footerMessage;

    static string toplevelXmlFile;
    static string toplevelHtmlFile;
    static string toplevelPhotosCss;

    static void WriteProgramBanner()
      {
        System.Console.WriteLine("FlickrDownload 0.1 Copyright(C) 2007 Brian Masney <masneyb@gftp.org>.");
        System.Console.WriteLine("If you have any questions, comments, or suggestions about this program, please");
        System.Console.WriteLine("feel free to email them to me. You can always find out the latest news about");
        System.Console.WriteLine("FlickrDownload from my website at http://www.gftp.org/FlickrDownload/");
        System.Console.WriteLine("");
        System.Console.WriteLine("FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING");
        System.Console.WriteLine("file. This is free software, and you are welcome to redistribute it under");
        System.Console.WriteLine("certain conditions; for details, see the COPYING file.");
        System.Console.WriteLine("");
      }

    static void usage()
      {
        System.Console.WriteLine("FlickrDownload [--xslt-only] [--dont-download-photos] [--dont-download-photo-privacy] <output directory> [Flickr username] [HTML footer message]");
        System.Environment.Exit (1);
      }

    static void initialize(string[] argv)
      {
        WriteProgramBanner();

        int curArgPos = 0;
        if (argv.Length < curArgPos)
          usage ();

        while (argv[curArgPos].StartsWith ("-"))
          {
            if (argv[curArgPos].Equals("--xslt-only"))
              xsltModeOnly = true;
            else if (argv[curArgPos].Equals("--dont-download-photos"))
              downloadPhotos = false;
            else if (argv[curArgPos].Equals("--dont-download-photo-privacy"))
              downloadPhotoPrivacy = false;
            else
              usage ();

            curArgPos++;
          }

        if (argv.Length < curArgPos)
          usage ();
        outputPath = argv[curArgPos++];

        if (argv.Length > curArgPos)
          flickrUsername = argv[curArgPos++];

        if (argv.Length > curArgPos)
          footerMessage = argv[curArgPos++];

        if (argv.Length > curArgPos)
          usage ();
       
        System.IO.Directory.CreateDirectory (outputPath);

        toplevelXmlFile = System.IO.Path.Combine (outputPath, "sets.xml");
        toplevelHtmlFile = System.IO.Path.Combine (outputPath, "index.html");
        toplevelPhotosCss = System.IO.Path.Combine (outputPath, "photos.css");

        xsltBasePath = System.IO.Path.Combine (System.IO.Path.GetDirectoryName (System.Reflection.Assembly.GetExecutingAssembly().Location), "..");
      }


    static string getSetPhotoSetXmlFile(string photoSetId)
      {
        string setDirectory = System.IO.Path.Combine (outputPath, photoSetId);
        return (System.IO.Path.Combine (setDirectory, "photos.xml"));
      }

    static string getSetPhotoSetHtmlFile(string photoSetId)
      {
        string setDirectory = System.IO.Path.Combine (outputPath, photoSetId);
        return (System.IO.Path.Combine (setDirectory, "index.html"));
      }

    static void addXmlTextNode (System.Xml.XmlDocument xmlDoc, System.Xml.XmlElement parent, string name, string value)
      {
        System.Xml.XmlElement element = xmlDoc.CreateElement (name);
        parent.AppendChild (element);

        if (value != "")
          {
            System.Xml.XmlText text = xmlDoc.CreateTextNode (value);
            element.AppendChild (text);
          }
      }

    static void PerformXsltTransformation(string xsltSetting, string xmlFile, string outputFile)
      {
        string xsltFile = System.Configuration.ConfigurationManager.AppSettings[xsltSetting];
        if (xsltFile == null || xsltFile == "")
          {
            System.Console.WriteLine ("The setting " + xsltSetting + " is not set in the application config file.");
            System.Environment.Exit (1);
          }

        xsltFile = System.IO.Path.Combine (xsltBasePath, xsltFile);

        System.Console.WriteLine ("Performing XSLT transformation on " + xmlFile + " using " + xsltFile + ". " + outputFile + " will be created.");

        try
          {
            System.Xml.XPath.XPathDocument xPathDoc = new System.Xml.XPath.XPathDocument (xmlFile);

            System.Xml.Xsl.XslTransform xsltTrans = new System.Xml.Xsl.XslTransform ();
            xsltTrans.Load (xsltFile);
            
            MultiOutput.MultiXmlTextWriter outputXHtml = new MultiOutput.MultiXmlTextWriter (outputFile, null);

            xsltTrans.Transform (xPathDoc, null, outputXHtml);        

            outputXHtml.Close() ;
          }
        catch (System.Exception e)
          {
            System.Console.WriteLine ("Error performing the XSLT transformation: " + e.Message);
          }
      }

    static void CopyPhotosDotCSS ()
      {
        string sourceFile = System.Configuration.ConfigurationManager.AppSettings["photosCssFile"];
        if (sourceFile == null || sourceFile == "")
          {
            System.Console.WriteLine ("The setting photosCssFile is not set in the application config file.");
            System.Environment.Exit (1);
          }

        sourceFile = System.IO.Path.Combine (xsltBasePath, sourceFile);
        System.Console.WriteLine ("Copying " + sourceFile + " to " + toplevelPhotosCss);
        System.IO.File.Copy (sourceFile, toplevelPhotosCss, true);
      }

    static void lookupUserNameInTopLevelXmlFile ()
      {
        if (flickrUsername != null)
          return;

        System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument ();
        xmlDoc.Load (toplevelXmlFile);

        System.Xml.XmlNodeList nameNodes = xmlDoc.GetElementsByTagName ("flickrUsername");
        if (nameNodes.Count == 0 || nameNodes[0].ChildNodes.Count == 0 ||
            nameNodes[0].ChildNodes[0].Value == null)
          return;

        flickrUsername = nameNodes[0].ChildNodes[0].Value;
      }

    static void performXsltOnlyMode ()
      {
        System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument ();
        xmlDoc.Load (toplevelXmlFile);

        foreach (System.Xml.XmlNode dirNode in xmlDoc.GetElementsByTagName ("directory"))
          {
            string photoSetId = dirNode.ChildNodes[0].Value;

            string xmlFile = getSetPhotoSetXmlFile(photoSetId);
            string htmlFile = getSetPhotoSetHtmlFile(photoSetId);
            PerformXsltTransformation("setXsltFile", xmlFile, htmlFile);
          }

        PerformXsltTransformation("allSetsXsltFile", toplevelXmlFile, toplevelHtmlFile);
        CopyPhotosDotCSS ();
      }



    static void WriteAuthToken(string authToken)
      {
        Configuration config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None); 
        config.AppSettings.Settings.Add ("flickrAuthToken", authToken);
        config.Save();
      }

    static void initFlickrSession()
      {
        lookupUserNameInTopLevelXmlFile ();
        if (flickrUsername == null)
          {
            System.Console.WriteLine ("Error: A Flickr username was not specified on the command line,");
            System.Console.WriteLine ("nor could it be found in the XML file");
            System.Console.WriteLine (toplevelXmlFile);
            System.Environment.Exit (1);
          }

        flickr = new FlickrNet.Flickr ("16c1a6a31f28e670500d02f6b13935b1", "0fa4d39da5eab415");

        string authToken = System.Configuration.ConfigurationManager.AppSettings["flickrAuthToken"];
        while (authToken == null || authToken.Length == 0)
          {
            string Frob = flickr.AuthGetFrob();
            string url = flickr.AuthCalcUrl(Frob, FlickrNet.AuthLevel.Read);

            System.Console.WriteLine ("Is it OK to open the following URL in your web browser?");
            System.Console.WriteLine ("");
            System.Console.WriteLine("\t" + url);
            System.Console.WriteLine ("");

            string response;
            do
              {
                System.Console.WriteLine ("Please enter 'y' or 'n'.");
                response = System.Console.ReadLine();
                if (response.ToLower() == "n" || response.ToLower() == "no")
                  System.Environment.Exit (1);
              }
            while (response.ToLower() != "y" && response.ToLower() != "yes");

            System.Console.WriteLine ("");
            System.Console.WriteLine ("Opening URL. Press enter once you have authenticated the application");
            System.Console.WriteLine ("with Flickr inside your web browser.");

            OpenLink (url);
        
            System.Console.ReadLine();

            try
              {
                FlickrNet.Auth auth = flickr.AuthGetToken(Frob);
                if (auth != null) 
                  {
                    authToken = auth.Token;
                    WriteAuthToken(authToken);
                  }
              }
            catch (FlickrNet.FlickrApiException e)
              {
                System.Console.WriteLine ("");
                System.Console.WriteLine("Error receiving the authentication token: " + e);
                System.Console.WriteLine ("");
              }
          }
       
        flickr.AuthToken = authToken;
      }

    // This code was derived from:
    // http://www.mono-project.com/Howto_OpenBrowser
    public static bool OpenLink(string address)
      {
        try
          {
            System.Diagnostics.Process proc;
            int plat = (int) System.Environment.OSVersion.Platform;

            if ((plat != 4) && (plat != 128))
              {
                // Use Microsoft's way of opening sites
                proc = System.Diagnostics.Process.Start(address);
              }
            else
              {
                string cmdline = System.String.Format("firefox {0} || " +
                      "mozilla-firefox {0} || konqueror {0} || " + 
                      "gnome-open {0} || open {0}",
                      address.Replace("&", "\\&"));

                proc = System.Diagnostics.Process.Start (cmdline);
              }

            // Sleep some time to wait for the shell to return in case of error
            System.Threading.Thread.Sleep(250);

            // If the exit code is zero or the process is still running then
            // appearently we have been successful.
            return (!proc.HasExited || proc.ExitCode == 0);
          }
        catch (System.Exception)
          {
            // We don't want any surprises
            return false;
          }
      }

    static void DownloadPhotoSet(FlickrNet.Photoset set)
      {
        string setDirectory = System.IO.Path.Combine (outputPath, set.PhotosetId);
        System.IO.Directory.CreateDirectory (setDirectory);

        System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument ();
        System.Xml.XmlNode xmlNode = xmlDoc.CreateNode (System.Xml.XmlNodeType.XmlDeclaration, "", "");
        xmlDoc.AppendChild (xmlNode);

        System.Xml.XmlElement setTopLevelXmlNode = xmlDoc.CreateElement ("set");
        xmlDoc.AppendChild (setTopLevelXmlNode);

        addXmlTextNode (xmlDoc, setTopLevelXmlNode, "title", set.Title);
        addXmlTextNode (xmlDoc, setTopLevelXmlNode, "description", set.Description);

        if (footerMessage != null)
          addXmlTextNode (xmlDoc, setTopLevelXmlNode, "footerMessage", footerMessage);

        foreach (FlickrNet.Photo photo in flickr.PhotosetsGetPhotos (set.PhotosetId).PhotoCollection)
          {
            System.Xml.XmlElement photoXmlNode = xmlDoc.CreateElement ("photo");
            setTopLevelXmlNode.AppendChild (photoXmlNode);

            FlickrNet.PhotoInfo pi = flickr.PhotosGetInfo (photo.PhotoId);
            
            string thumbUrl = photo.SquareThumbnailUrl;
            string thumbFile = photo.PhotoId + "_thumb_sq.jpg";
            DownloadPicture (thumbUrl, System.IO.Path.Combine (setDirectory, thumbFile));
            addXmlTextNode (xmlDoc, photoXmlNode, "thumbnailFile", thumbFile);
            
            string medUrl = photo.MediumUrl;
            string medFile = photo.PhotoId + "_med.jpg";
            DownloadPicture (medUrl, System.IO.Path.Combine (setDirectory, medFile));
            addXmlTextNode (xmlDoc, photoXmlNode, "mediumFile", medFile);
            
            // The original image is only available to Pro users...
            try
              {
                string origUrl = photo.OriginalUrl;
                string origFile = photo.PhotoId + "_orig.jpg";
                DownloadPicture (origUrl, System.IO.Path.Combine (setDirectory, origFile));
                addXmlTextNode (xmlDoc, photoXmlNode, "originalFile", origFile);
              }
            catch (System.Exception e)
              {
                System.Console.WriteLine("Error retrieving the original photo: " + e.Message);
              }

            addXmlTextNode (xmlDoc, photoXmlNode, "id", photo.PhotoId);
            addXmlTextNode (xmlDoc, photoXmlNode, "title", photo.Title);
            addXmlTextNode (xmlDoc, photoXmlNode, "description", pi.Description);
            addXmlTextNode (xmlDoc, photoXmlNode, "dateTaken", photo.DateTaken.ToString());
            addXmlTextNode (xmlDoc, photoXmlNode, "dateUploaded", photo.DateUploaded.ToString());
            addXmlTextNode (xmlDoc, photoXmlNode, "license", photo.License);
            addXmlTextNode (xmlDoc, photoXmlNode, "tags", photo.CleanTags);
            
            if (downloadPhotoPrivacy)
              {
                try
                  {
                    FlickrNet.PhotoPermissions privacy = flickr.PhotosGetPerms (photo.PhotoId);
                    
                    if (privacy.IsPublic)
                      addXmlTextNode (xmlDoc, photoXmlNode, "privacy", "public");
                    else if (privacy.IsFamily && privacy.IsFriend)
                      addXmlTextNode (xmlDoc, photoXmlNode, "privacy", "friend/family");
                    else if (privacy.IsFamily)
                      addXmlTextNode (xmlDoc, photoXmlNode, "privacy", "family");
                    else if (privacy.IsFriend)
                      addXmlTextNode (xmlDoc, photoXmlNode, "privacy", "friend");
                    else
                      addXmlTextNode (xmlDoc, photoXmlNode, "privacy", "private");
                  }
                catch (FlickrNet.FlickrApiException)
                  {
                  }
              }
          }

        string xmlFile = getSetPhotoSetXmlFile(set.PhotosetId);
        xmlDoc.Save (xmlFile);

        string htmlFile = getSetPhotoSetHtmlFile(set.PhotosetId);
        PerformXsltTransformation("setXsltFile", xmlFile, htmlFile);
      }

    static void DownloadPicture (string url, string fileName)
      {
        if (!downloadPhotos)
          return;

        if (System.IO.File.Exists (fileName))
          {
            System.Console.WriteLine ("Skipping file " + fileName + " since it has already been downloaded.");
            return;
          }
                  
        System.Console.WriteLine ("Downloading file " + fileName);
                
        System.IO.Stream input = flickr.DownloadPicture (url);
        System.IO.FileStream output = System.IO.File.Create (fileName);
                
        int numBytes;
        const int size = 8192;
        byte[] bytes = new byte[size];
        
        while((numBytes = input.Read (bytes, 0, size)) > 0)
          output.Write(bytes, 0, numBytes);
          
        input.Close ();
        output.Close ();
      }



    static int Main (string[] argv)
      {
        initialize (argv);
        if (xsltModeOnly)
          {
            performXsltOnlyMode ();
            return 0;
          }

        initFlickrSession();

        System.Console.WriteLine ("Downloading photo set information for user '" + flickrUsername + "'");

        FlickrNet.Photosets sets;
        try
          {
            sets = flickr.PhotosetsGetList (flickr.PeopleFindByUsername (flickrUsername).UserId);
          }
        catch (FlickrNet.FlickrException ex)
          {
            System.Console.WriteLine ("Error retrieving photos for user " + flickrUsername + ": " + ex.Message);
            return 1;
          }
          
        System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument ();
        System.Xml.XmlNode xmlNode = xmlDoc.CreateNode (System.Xml.XmlNodeType.XmlDeclaration, "", "");
        xmlDoc.AppendChild (xmlNode);

        System.Xml.XmlElement setTopLevelXmlNode = xmlDoc.CreateElement ("sets");
        xmlDoc.AppendChild (setTopLevelXmlNode);

        addXmlTextNode (xmlDoc, setTopLevelXmlNode, "flickrUsername", flickrUsername);
        addXmlTextNode (xmlDoc, setTopLevelXmlNode, "title", "Photos from " + flickrUsername);
        addXmlTextNode (xmlDoc, setTopLevelXmlNode, "description", "");

        if (footerMessage != null)
          addXmlTextNode (xmlDoc, setTopLevelXmlNode, "footerMessage", footerMessage);

        foreach (FlickrNet.Photoset set in sets.PhotosetCollection)
          {
            System.Xml.XmlElement setXmlNode = xmlDoc.CreateElement ("set");
            setTopLevelXmlNode.AppendChild (setXmlNode);
            
            addXmlTextNode (xmlDoc, setXmlNode, "title", set.Title);
            addXmlTextNode (xmlDoc, setXmlNode, "directory", set.PhotosetId);

            string primaryPhoto = set.PrimaryPhotoId + "_thumb.jpg";
            addXmlTextNode (xmlDoc, setXmlNode, "thumbnailFile", set.PhotosetId + "/" + primaryPhoto);

            DownloadPhotoSet (set);
          }
          
        xmlDoc.Save (toplevelXmlFile);

        PerformXsltTransformation("allSetsXsltFile", toplevelXmlFile, toplevelHtmlFile);
        CopyPhotosDotCSS ();

        return 0;
      }
  }

}
