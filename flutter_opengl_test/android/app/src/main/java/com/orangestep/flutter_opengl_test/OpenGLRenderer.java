package com.orangestep.flutter_opengl_test;

import android.graphics.SurfaceTexture;
import android.opengl.GLUtils;
import android.util.Log;

import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.egl.EGLContext;
import javax.microedition.khronos.egl.EGLDisplay;
import javax.microedition.khronos.egl.EGLSurface;

public class OpenGLRenderer implements Runnable {
    protected final SurfaceTexture texture;
    private EGL10 egl;
    private EGLDisplay eglDisplay;
    private EGLContext eglContext;
    private EGLSurface eglSurface;

    private boolean running;

    private Worker worker;

    // ...

    @Override
    public void run() {
        initGL();
        worker.onCreate();
        Log.d(LOG_TAG, "OpenGL init OK.");

        while (running) {
            long loopStart = System.currentTimeMillis();

            if (worker.onDraw()) {
                if (!egl.eglSwapBuffers(eglDisplay, eglSurface)) {
                    Log.d(LOG_TAG, String.valueOf(egl.eglGetError()));
                }
            }

            long waitDelta = 16 - (System.currentTimeMillis() - loopStart);
            if (waitDelta > 0) {
                try {
                    Thread.sleep(waitDelta);
                } catch (InterruptedException e) {
                }
            }
        }

        worker.onDispose();
        deinitGL();
    }

    private void deinitGL() {

    }

    private void initGL() {
        egl = (EGL10) EGLContext.getEGL();
        eglDisplay = egl.eglGetDisplay(EGL10.EGL_DEFAULT_DISPLAY);
        if (eglDisplay == EGL10.EGL_NO_DISPLAY) {
            throw new RuntimeException("eglGetDisplay failed");
        }

        int[] version = new int[2];
        if (!egl.eglInitialize(eglDisplay, version)) {
            throw new RuntimeException("eglInitialize failed");
        }

        EGLConfig eglConfig = chooseEglConfig();
        eglContext = createContext(egl, eglDisplay, eglConfig);

        eglSurface = egl.eglCreateWindowSurface(eglDisplay, eglConfig, texture, null);

        if (eglSurface == null || eglSurface == EGL10.EGL_NO_SURFACE) {
            throw new RuntimeException("GL Error: " + GLUtils.getEGLErrorString(egl.eglGetError()));
        }

        if (!egl.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)) {
            throw new RuntimeException("GL make current error: " + GLUtils.getEGLErrorString(egl.eglGetError()));
        }
    }

    // ...

    public interface Worker {
        void onCreate();

        boolean onDraw();

        void onDispose();
    }
}
