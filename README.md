# FlickrDownload

FlickrDownload is a program that runs from the command that allows you to
download all of your photos and the associated metadata from Flickr. The
metadata is stored in a XML file and a series of HTML files are generated
so that you have a fully-functioning static copy of your Flickr account on
your local computer. It supports the following features:

- Downloads information about all of your sets and collections.
- Supports downloading photos and videos.
- Downloads the following image sizes: small square, medium and full-sized
  images.
- A statistics page is generated with the following information: privacy stats
  (# of public and private photos), number of photos tagged, number of photos
  geotagged, disk space usage, photo licenses used, stats for each set (disk
  space and number of photos). The statistics are broken out separately for
  photos and videos.
- The statistics page will show you if you have any photos or videos that were
  uploaded multiple times.
- All data is stored in an open format for the long-term preservation of your
  data.


## Screenshots

Screenshots are available in the [screenshots](screenshots) directory.


## Binaries

A precompiled version of FlickrDownload is available in the [binaries](binaries)
directory for those wishing to not compile from source themselves.


## How to run

In the build directory, you will see a FlickrDownload.jar file, along with
several other files that end in jar. Type
`java -jar FlickrDownload.jar` and you should see something like this:

    FlickrDownload 0.6 - Copyright(C) 2007,2010 Brian Masney <masneyb@onstation.org>.
    If you have any questions, comments, or suggestions about this program, please
    feel free to email them to me. You can always find out the latest news about
    FlickrDownload from my website at http://www.onstation.org/flickrdownload/.
    
    FlickrDownload is distributed under the terms of the GPLv3 and comes with
    ABSOLUTELY NO WARRANTY; for details, see the COPYING file. This is free
    software, and you are welcome to redistribute it under certain conditions;
    for details, see COPYING file.
    
    Option "--photosDir" is required
    usage: FlickrDownload  [--addExtensionToUnknownFiles VAL] [--authDir VAL] [--authUsername VAL] [--debug] [--downloadExifData] [--onlyData] [--onlyOriginals] [--limitToSet VAL ...] [--partial] --photosDir VAL [--photosUsername VAL]
    
I typically run it like this:

`java -Xmx2048m -jar /home/masneyb/src/flickrdownload/build/FlickrDownload.jar --partial --photosDir /path/to/flickr/backup --addExtensionToUnknownFiles todelete --downloadExifData`

You will have to specify the --authUsername option the first time that you run
the program to authenticate FlickrDownload with your flickr account. The
authentication token is stored in the same directory with your Flickr backup.

Once the backup is finished, open the sets.html file in your web browser.

