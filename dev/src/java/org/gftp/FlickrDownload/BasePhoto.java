package org.gftp.FlickrDownload;

import com.aetrion.flickr.photos.Photo;

public class BasePhoto {
	private String photoId;
	private String secret;

	public BasePhoto(Photo photo) {
		this.photoId = photo.getId();
		this.secret = photo.getSecret();
	}

	public String getPhotoId() {
		return this.photoId;
	}

	public void setPhotoId(String photoId) {
		this.photoId = photoId;
	}

	public String getSecret() {
		return this.secret;
	}

	public void setSecret(String secret) {
		this.secret = secret;
	}
}
