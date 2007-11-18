namespace org.gftp
{

static class FlickrDownload
  {
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
        System.Console.WriteLine("FlickrDownload <username> [output directory]");
        System.Console.WriteLine("");
        System.Console.WriteLine("Note: You may have to enclose your username in quotes (\") if it has spaces.");
      }

    static FlickrNet.Flickr initFlickrSession()
      {
        FlickrNet.Flickr flickr = new FlickrNet.Flickr ("16c1a6a31f28e670500d02f6b13935b1", "0fa4d39da5eab415");

        flickr.AuthToken = "FIXME";
        /*
        string Frob = flickr.AuthGetFrob();
        string url = flickr.AuthCalcUrl(Frob, AuthLevel.Read);
        System.Console.WriteLine(url);
        
        System.Console.ReadLine();
        
        Auth auth = flickr.AuthGetToken(Frob);
        string token = auth.Token;
        
        System.Console.WriteLine("Token is " + token);
        */

        return flickr;
      }

    static void DownloadPhotoSet(FlickrNet.Flickr flickr, FlickrNet.Photoset set, string outputPath)
      {
        string setDirectory = System.IO.Path.Combine (outputPath, set.PhotosetId);
        System.IO.Directory.CreateDirectory (setDirectory);

        System.IO.StreamWriter output = new System.IO.StreamWriter (System.IO.Path.Combine (setDirectory, "photos.xml"), false);

        output.WriteLine ("<set><title>" + set.Title + "</title><description>" + set.Description + "</description>");
            
        foreach (FlickrNet.Photo photo in flickr.PhotosetsGetPhotos (set.PhotosetId).PhotoCollection)
          {
            FlickrNet.PhotoInfo pi = flickr.PhotosGetInfo (photo.PhotoId);
            
            string thumbUrl = photo.ThumbnailUrl;
            string thumbFile = photo.PhotoId + "_thumb.jpg";
            DownloadPicture (flickr, thumbUrl, System.IO.Path.Combine (setDirectory, thumbFile));
            
            string medUrl = photo.MediumUrl;
            string medFile = photo.PhotoId + "_med.jpg";
            DownloadPicture (flickr, medUrl, System.IO.Path.Combine (setDirectory, medFile));
            
            string origUrl = photo.OriginalUrl;
            string origFile = photo.PhotoId + "_orig.jpg";
            DownloadPicture (flickr, origUrl, System.IO.Path.Combine (setDirectory, origFile));

            output.WriteLine ("<photo>");
            output.WriteLine ("<id>" + photo.PhotoId + "</id>");
            output.WriteLine ("<title>" + photo.Title + "</title>");
            output.WriteLine ("<description>" + pi.Description + "</description>");
            output.WriteLine ("<dateTaken>" + photo.DateTaken + "</dateTaken>");
            output.WriteLine ("<tags>" + photo.CleanTags + "</tags>");
            
            try
              {
                FlickrNet.PhotoPermissions privacy = flickr.PhotosGetPerms (photo.PhotoId);
                output.WriteLine ("<privacy>");
                
                if (privacy.IsPublic)
                  output.WriteLine ("<public/>");
                else
                  {
                    if (privacy.IsFamily)
                      output.WriteLine ("<family/>");
                    if (privacy.IsFriend)
                      output.WriteLine ("<friend/>");
                  }
                  
                output.WriteLine ("</privacy>");
              }
            catch (FlickrNet.FlickrApiException)
              {
              }

            output.WriteLine ("<originalFile>" + origFile + "</originalFile>");
            output.WriteLine ("<mediumFile>" + medFile + "</mediumFile>");
            output.WriteLine ("<thumbnailFile>" + thumbFile + "</thumbnailFile>");
            
            output.WriteLine ("</photo>");
          }

        output.WriteLine ("</set>");
        output.Close ();
      }

    static void DownloadPicture (FlickrNet.Flickr flickr, string url, string fileName)
      {
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
        WriteProgramBanner();

        if (argv.Length < 1 || argv.Length > 2)
          {
            usage();
            return 1;
          }

        string outputPath;
        if (argv.Length == 2)
          outputPath = argv[1];
        else
          outputPath = ".";


        System.Console.WriteLine ("Downloading photo set information for user '" + argv[0] + "'");

        FlickrNet.Flickr flickr = initFlickrSession();
        FlickrNet.Photosets sets;
        try
          {
            sets = flickr.PhotosetsGetList (flickr.PeopleFindByUsername (argv[0]).UserId);
          }
        catch (FlickrNet.FlickrException ex)
          {
            System.Console.WriteLine ("Error retrieving photos for user " + argv[0] + ": " + ex.Message);
            return 1;
          }
          
        System.IO.StreamWriter setOutput = new System.IO.StreamWriter (System.IO.Path.Combine (outputPath, "sets.xml"), false);
        setOutput.WriteLine ("<sets>");
        
        foreach (FlickrNet.Photoset set in sets.PhotosetCollection)
          {
            string primaryPhoto = set.PrimaryPhotoId + "_thumb.jpg";
            setOutput.WriteLine ("<set><title>" + set.Title + "</title><directory>" + set.PhotosetId + "</directory><thumbnailFile>" + set.PhotosetId + "/" + primaryPhoto + "</thumbnailFile></set>");

            DownloadPhotoSet (flickr, set, outputPath);
          }
          
        setOutput.WriteLine ("</sets>");
        setOutput.Close ();

        return 0;
      }
  }

}
