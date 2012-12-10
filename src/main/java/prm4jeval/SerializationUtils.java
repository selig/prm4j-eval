/*
 * Copyright (c) 2012 Mateusz Parzonka, Eric Bodden
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * Mateusz Parzonka - initial API and implementation
 */
package prm4jeval;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

/**
 * Provides methods to serialize and deserialize objects to/from disk.
 */
public class SerializationUtils {

    /**
     * @param object
     *            object to be serialized
     * @param filePath
     *            the object will be written at this location, directories will be created according to path
     * @throws Exception
     */
    public static void serializeToFile(Serializable object, String filePath) {
	File file = new File(filePath);
	ObjectOutputStream out = null;
	try {
	    makeDirectory(new File(getBasePath(filePath)));
	    out = new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(file)));
	} catch (FileNotFoundException e) {
	    throw new SerializationException(e);
	} catch (IOException e) {
	    throw new SerializationException(e);
	}
	try {
	    out.writeObject(object);
	    out.flush();
	} catch (IOException ex) {
	    throw new SerializationException(ex);
	} finally {
	    try {
		if (out != null) {
		    out.close();
		}
	    } catch (IOException ex) {
		// ignore close exception
	    }
	}
    }

    /**
     * Deserializes an object from disk.
     *
     * @param filePath
     * @return an object. Clients have to cast the object to the expected type.
     * @throws SerializationException
     *             a runtime exception
     */
    public static Object deserializeFromFile(String filePath) {
	ObjectInputStream in;
	try {
	    in = new ObjectInputStream(new FileInputStream(new File(filePath)));
	} catch (FileNotFoundException e) {
	    throw new SerializationException(e);
	} catch (IOException e) {
	    throw new SerializationException(e);
	}
	try {
	    return in.readObject();

	} catch (ClassNotFoundException e) {
	    throw new SerializationException(e);
	} catch (IOException e) {
	    throw new SerializationException(e);
	} finally {
	    try {
		if (in != null) {
		    in.close();
		}
	    } catch (IOException e) {
		// ignore close exception
	    }
	}
    }

    public static void makeDirectory(File directory) throws IOException {
	if (directory.exists()) {
	    if (!directory.isDirectory()) {
		throw new IOException("File " + directory + " exists and is "
			+ "not a directory. Directory was not created.");
	    }
	} else {
	    if (!directory.mkdirs()) {
		if (!directory.isDirectory()) {
		    throw new IOException("Directory could not be created since another "
			    + "thread wrote a file in the mean time: " + directory);
		}
	    }
	}
    }

    public static String getBaseName(String path) {
	String[] split = new File(path).getAbsolutePath().split(File.separator);
	return split[split.length - 1];
    }

    public static String getBasePath(String path) {
	String absPath = new File(path).getAbsolutePath();
	return absPath.substring(0, absPath.length() - getBaseName(path).length() - 1);
    }

    public static class SerializationException extends RuntimeException {

	private static final long serialVersionUID = 1L;

	public SerializationException(Exception ex) {
	    super(ex);
	}

    }

}
