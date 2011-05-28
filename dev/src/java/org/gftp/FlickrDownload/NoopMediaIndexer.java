package org.gftp.FlickrDownload;

import java.io.IOException;
import java.util.Collection;
import java.util.Collections;

import org.jdom.Element;

public class NoopMediaIndexer implements MediaIndexer {
	public static NoopMediaIndexer INSTANCE = new NoopMediaIndexer();

	public void addToIndex(String setId, Element mediaElement) {
		// NOOP
	}

	public Collection<String> writeIndex() throws IOException {
		return Collections.EMPTY_LIST;
	}

}
