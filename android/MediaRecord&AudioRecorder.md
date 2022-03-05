title: MediaRecord&AudioRecorder
date: 2019年03月17日23:32:46
categories: 未标记
tags: 
     - 未标记
cover_picture: /images/MediaRecord&AudioRecorder.jpeg
---
    
##### AudioRecord（基于字节流录音）

- 录制最原始的PCM流数据（PCM编码压缩后可为AMR、MP3、AAC），需要用AudioTrack播放。
- 可以实现语音的实时处理，进行边录边播，对音频的实时处理。

###### 代码

```java
package com.gusi.study.media;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;
import android.os.Environment;
import android.util.Log;

import com.blankj.utilcode.util.CloseUtils;
import com.blankj.utilcode.util.ToastUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @Author ylw  2019/2/18 20:27
 */
public class Audio {
    private static final int BUFFER_SIZE = 2048;//buffer值不能太大，避免OOM
    private volatile boolean mIsRecording;
    private final ExecutorService mService;
    private long mBeginTime;
    private File mAudioRecordFile;
    private FileOutputStream mAudioRecordFos;
    private AudioRecord mAudioRecord;
    private byte[] mBuffer;

    public Audio() {
        mService = Executors.newSingleThreadExecutor();
        mBuffer = new byte[BUFFER_SIZE];
    }

    public void record() {
        if (mIsRecording) {
            ToastUtils.showShort("Audio正在录音: " + (System.currentTimeMillis() - mBeginTime));
            return;
        }
        mService.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    //记录开始录音时间
                    mBeginTime = System.currentTimeMillis();
                    //创建录音文件
                    mAudioRecordFile = new File(Environment.getExternalStorageDirectory()
                            .getAbsolutePath() +
                            "/recorderDemo/" + System.currentTimeMillis() + ".pcm");
                    File recordFileParentFile = mAudioRecordFile.getParentFile();
                    if (!recordFileParentFile.exists()) recordFileParentFile.mkdirs();
                    mAudioRecordFile.createNewFile();
                    Log.w("Fire", "MediaActivity:170行:" + mAudioRecordFile.getPath());
                    //创建文件输出流
                    mAudioRecordFos = new FileOutputStream(mAudioRecordFile);
                    //配置AudioRecord
                    int audioSource = MediaRecorder.AudioSource.MIC;
                    //所有android系统都支持
                    int sampleRate = 44100;
                    //单声道输入
                    int channelConfig = AudioFormat.CHANNEL_IN_MONO;
                    //PCM_16是所有android系统都支持的
                    int audioFormat = AudioFormat.ENCODING_PCM_16BIT;
                    //计算AudioRecord内部buffer最小
                    int minBufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat);
                    //buffer不能小于最低要求，也不能小于我们每次我们读取的大小。
                    mAudioRecord = new AudioRecord(audioSource, sampleRate, channelConfig, audioFormat, Math.max(minBufferSize, BUFFER_SIZE));

                    mIsRecording = true;
                    //开始录音
                    mAudioRecord.startRecording();
                    //循环读取数据，写入输出流中
                    while (mIsRecording) {
                        //只要还在录音就一直读取
                        int read = mAudioRecord.read(mBuffer, 0, BUFFER_SIZE);
                        if (read > 0) {
                            mAudioRecordFos.write(mBuffer, 0, read);
                        }
                    }
                    //退出循环，停止录音，释放资源
                    if (mAudioRecord != null) {
                        mAudioRecord.stop();
                        mAudioRecord.release();
                        mAudioRecord = null;
                        Log.w("Fire", "MediaActivity:213行:Audio 录音" + (System.currentTimeMillis() - mBeginTime));
                    }
                    CloseUtils.closeIO(mAudioRecordFos);
                } catch (IOException e) {
                    Log.e("Fire", "MediaActivity:163行:" + e.toString());
                    mAudioRecord = null;
                }
            }
        });
    }

    public void stop() {
        if (!mIsRecording) {
            ToastUtils.showShort("Audio 没有在录音!");
            return;
        }
        mIsRecording = false;
    }

    public void play() {
        if (mIsRecording) {
            ToastUtils.showShort("Audio 正在录音!");
            return;
        }
        mService.execute(new Runnable() {
            @Override
            public void run() {
                Log.w("Fire", "MediaActivity:167行:" + mAudioRecordFile);
                if (mAudioRecordFile != null) {
                    //配置播放器
                    //音乐类型，扬声器播放
                    int streamType = AudioManager.STREAM_MUSIC;
                    //录音时采用的采样频率，所以播放时同样的采样频率
                    int sampleRate = 44100;
                    //单声道，和录音时设置的一样
                    int channelConfig = AudioFormat.CHANNEL_OUT_MONO;
                    //录音时使用16bit，所以播放时同样采用该方式
                    int audioFormat = AudioFormat.ENCODING_PCM_16BIT;
                    //流模式
                    int mode = AudioTrack.MODE_STREAM;
                    //计算最小buffer大小
                    int minBufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, audioFormat);
                    //构造AudioTrack  不能小于AudioTrack的最低要求，也不能小于我们每次读的大小
                    AudioTrack audioTrack = new AudioTrack(streamType, sampleRate, channelConfig, audioFormat, Math.max(minBufferSize, BUFFER_SIZE), mode);
                    audioTrack.play();
                    //从文件流读数据
                    FileInputStream is = null;
                    try {
                        //循环读数据，写到播放器去播放
                        is = new FileInputStream(mAudioRecordFile);
                        //循环读数据，写到播放器去播放
                        int read;
                        //只要没读完，循环播放
                        while ((read = is.read(mBuffer)) > 0) {
                            int ret = audioTrack.write(mBuffer, 0, read);
                            //检查write的返回值，处理错误
                            switch (ret) {
                                case AudioTrack.ERROR_INVALID_OPERATION:
                                case AudioTrack.ERROR_BAD_VALUE:
                                case AudioManager.ERROR_DEAD_OBJECT:
                                    ToastUtils.showShort("播放失败!");
                                    return;
                                default:
                                    break;
                            }
//                            audioTrack.play();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        Log.e("Fire", "MediaActivity:208行:" + e.toString());
                        //读取失败
                        ToastUtils.showShort("播放失败!");
                    } finally {
//                        mIsPlaying = false;
                        //关闭文件输入流
                        CloseUtils.closeIO(is);
                        //播放器释放
                        try {
                            audioTrack.stop();
                            audioTrack.release();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    //循环读数据，写到播放器去播放
                    //错误处理，防止闪退
                }
            }
        });
    }
}

```

##### MediaRecorder（基于文件录音）

- 已集成录音、编码、压缩等，支持少量的音频格式文件。
- 录制的音频是经过编码压缩后的（AMR、MP3、AAC），并存储为文件。
- 优点：封装度高，操作简单。
- 缺点：不能实时处理音频，输出音频格式少。

###### 代码

```java
/**
 * @Author ylw  2019/2/18 20:41
 */
public class Media {
    private final ExecutorService mService;
    private volatile MediaRecorder mMediaRecorder;
    private long mBeginTime;
    private File mFile;

    public Media() {
        mService = Executors.newSingleThreadExecutor();
    }

    /**
     * 录音
     */
    public void record() {
        mService.execute(new Runnable() {
            @Override
            public void run() {
                if (mMediaRecorder != null) {
                    ToastUtils.showShort("Media 正在录音");
                    return;
                }
                //实例化MediaRecorder对象
                mMediaRecorder = new MediaRecorder();
                //从麦克风采集声音数据
                mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
                //设置输出格式为MP4
                mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
                //设置采样频率44100 频率越高,音质越好,文件越大
                mMediaRecorder.setAudioSamplingRate(44100);
                //设置声音数据编码格式,音频通用格式是AAC
                mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
                //设置编码频率
                mMediaRecorder.setAudioEncodingBitRate(96000);
                //设置输出文件
                //创建录音文件
                mFile = new File(Environment.getExternalStorageDirectory()
                        .getAbsolutePath()
                        + "/recorderDemo/" + System.currentTimeMillis() + ".m4a");
                File parentFile = mFile.getParentFile();
                if (!parentFile.exists()) parentFile.mkdirs();
                //开始录音
                try {
                    mFile.createNewFile();
                    String path = mFile.getPath();
                    Log.w("Fire", "MediaActivity:50行:" + path);
                    mMediaRecorder.setOutputFile(path);
                    mMediaRecorder.prepare();
                    mMediaRecorder.start();
                    mBeginTime = System.currentTimeMillis();
                    ToastUtils.showShort("Media正在录音: ");
                } catch (IOException e) {
                    e.printStackTrace();
                    Log.e("Fire", "MediaActivity:109行:" + e.toString());
                    mMediaRecorder = null;
                }
            }
        });
    }

    /**
     * 停止
     */
    public void stop() {
        mService.execute(new Runnable() {
            @Override
            public void run() {
                if (mMediaRecorder == null) {
                    ToastUtils.showShort("Media 没有在录音!");
                    return;
                }
                mMediaRecorder.stop();
                mMediaRecorder.release();
                mMediaRecorder = null;
                ToastUtils.showShort("录音时间:" + (System.currentTimeMillis() - mBeginTime));
            }
        });
    }

    /**
     * 播放
     */
    public void play() {
        if (mFile == null) {
            ToastUtils.showShort("Media没有播放资源!");
            return;
        }
        final MediaPlayer mediaPlayer = new MediaPlayer();
        try {
            mediaPlayer.setDataSource(mFile.getPath());
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);

            // 通过异步的方式装载媒体资源
            mediaPlayer.prepareAsync();
            mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    // 装载完毕回调
                    mediaPlayer.start();
                }
            });
        } catch (IOException e) {

        } finally {

        }
        mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                if (mediaPlayer != null && mediaPlayer.isPlaying()) {
                    mediaPlayer.stop();
                    mediaPlayer.release();
                }
            }
        });
    }

}
```



##### MediaPlayer和AudioTrack

###### MediaPlayer

- 可播放多种格式的声音文件（MP3、AAC、WAV、OGG、MIDI等等）。
- 会在framework创建对应的**音频解码器**。
- 会在framework创建AudioTrack，把解码后的PCM流数据传递给AudioTrack，AudioTrack再传递给AudioFlinger进行混音，然后传给硬件播放。

###### AudioTrack

- 只能播放已经解码的PCM流，文件只支持不需要解码的wav。

##### PCM

PCM录音就是将声音等模拟信号变成符号化的脉冲列，再予以记录。PCM信号是由[1]、[0]等符号构成的数字信号，而未经过任何编码和压缩处理。与模拟信号比，它不易受传送系统的杂波及失真的影响。动态范围宽，可得到音质相当好的影响效果。也就是说，PCM就是没有压缩的编码方式，PCM文件就是采用PCM这种没有压缩的编码方式编码的音频数据文件。

##### 音频混合

- **音频混合原理**：量化的语音信号的叠加等价于空气中声波的叠加。
- 一段音频和另一端音频合在一起，能够同时播放（人声和背景音乐的合成）。
- 音频采样点数值的大小是（-32768,32767），对应short的最小值和最大值，音频采样点数据就是由一个个数值组成的的。如果单纯叠加，可能会造成相加后的值会大于32767，超出short的表示范围，也就是**溢出**，所以在音频混合上回采用一些算法进行处理。下面列举下简单的混合方式。

###### 直接叠加（可能溢出）

A（A1,A2,A3,A4）和B（B1,B2,B3,B4）叠加后得到C（（A1+B1）,（A2+B2）,（A3+B3）,（A4+B4））

###### 叠加后求平均值（避免溢出，两者声音比之前单独的都小一半）

A（A1,A2,A3,A4）和B（B1,B2,B3,B4）叠加后求平均值，得到C（（A1+B1）/2,（A2+B2）/2,（A3+B3）/2,（A4+B4）/2）

###### 权值叠加（依赖各自的权值）

A（A1,A2,A3,A4）和B（B1,B2,B3,B4）权值叠加，A权值为x，B权值为y，得到C（（A1 * x+B1 * y）,（A2 * x+B2 * y）,（A3 * x+B3 * y）,（A4 * x+B4 * y））

###### 注意事项

1. 确保A音频和B音频的采样位数一致。
2. 确保A音频和B音频的采样率一致。
3. 确保A音频和B音频的声道数一致。

###### 代码

```java
  /**
     * 权值叠加
     *
     * @param bMulRoadAudioes 声源
     * @param weights         权值（直接叠加为1、平均叠加为0.5）weights.length = bMulRoadAudioes.length
     * @return
     */
    public static byte[] mixRawAudioBytes(byte[][] bMulRoadAudioes, int[] weights) {
        if (bMulRoadAudioes == null || bMulRoadAudioes.length == 0) return null;

        byte[] realMixAudio = bMulRoadAudioes[0];
        if (bMulRoadAudioes.length == 1)
            return realMixAudio;
        // FIXME: 2019/2/18 数组等长
        for (int i = 0; i < bMulRoadAudioes.length; ++i) {
            if (bMulRoadAudioes[i].length != realMixAudio.length) {
                Log.e("Fire", "PCM:141行:column of the road of audio + " + i + " is diffrent.");
                return null;
            }
        }

        //row 代表参与合成的音频数量
        //column 代表一段音频的采样点数，这里所有参与合成的音频的采样点数都是相同的
        int row = bMulRoadAudioes.length;
        int column = realMixAudio.length / 2;
        short[][] sMulRoadAudioes = new short[row][column];

        //PCM音频16位的存储是大端存储方式，即低位在前，高位在后，例如(X1Y1, X2Y2, X3Y3)数据，
        // 它代表的采样点数值就是(（Y1 * 256 + X1）, （Y2 * 256 + X2）, （Y3 * 256 + X3）)
        for (int r = 0; r < row; ++r) {
            for (int c = 0; c < column; ++c) {
                sMulRoadAudioes[r][c] = (short) ((bMulRoadAudioes[r][c * 2] & 0xff) | (bMulRoadAudioes[r][c * 2 + 1] & 0xff) << 8);
            }
        }

        short[] sMixAudio = new short[column];
        int mixVal;
        int sr = 0;
        for (int sc = 0; sc < column; ++sc) {
            mixVal = 0;
            sr = 0;
            //这里采取累加法
            for (; sr < row; ++sr) {
//                mixVal += sMulRoadAudioes[sr][sc];
                int weight = weights[sr];//权值
                Log.w("Fire", "PCM:173行:" + weight);
                mixVal += sMulRoadAudioes[sr][sc] * weight;
            }
            //最终值不能大于short最大值，因此可能出现溢出
            sMixAudio[sc] = (short) (mixVal);
        }

        //short值转为大端存储的双字节序列
        for (sr = 0; sr < column; ++sr) {
            realMixAudio[sr * 2] = (byte) (sMixAudio[sr] & 0x00FF);
            realMixAudio[sr * 2 + 1] = (byte) ((sMixAudio[sr] & 0xFF00) >> 8);
        }

        return realMixAudio;
    }

    /**
     * 合成PCM 文件
     *
     * @param rawAudioFiles
     * @param destFile
     */
    public static void mixAudios(File[] rawAudioFiles, File destFile) {

        final int fileSize = rawAudioFiles.length;
        FileInputStream[] audioFileStreams = new FileInputStream[fileSize];
        File audioFile = null;

        FileInputStream inputStream = null;
        OutputStream output = null;
        BufferedOutputStream bufferedOutput = null;
        byte[][] allAudioBytes = new byte[fileSize][];
        boolean[] streamDoneArray = new boolean[fileSize];
        byte[] buffer = new byte[512];
        int offset;

        try {
            output = new FileOutputStream(destFile);
            bufferedOutput = new BufferedOutputStream(output);


            for (int fileIndex = 0; fileIndex < fileSize; ++fileIndex) {
                audioFile = rawAudioFiles[fileIndex];
                audioFileStreams[fileIndex] = new FileInputStream(audioFile);
            }
            while (true) {
                for (int streamIndex = 0; streamIndex < fileSize; ++streamIndex) {
                    inputStream = audioFileStreams[streamIndex];
                    if (!streamDoneArray[streamIndex] && (offset = inputStream.read(buffer)) != -1) {
                        allAudioBytes[streamIndex] = Arrays.copyOf(buffer, buffer.length);
                    } else {
                        streamDoneArray[streamIndex] = true;
                        allAudioBytes[streamIndex] = new byte[512];
                    }
                }
                int[] weights = new int[allAudioBytes.length];
                for (int i = 0; i < allAudioBytes.length; i++) {
                    weights[i] = 1;
                }


                byte[] mixBytes = mixRawAudioBytes(allAudioBytes, weights);
                bufferedOutput.write(mixBytes);
                //mixBytes 就是混合后的数据

                boolean done = true;
                for (boolean streamEnd : streamDoneArray) {
                    if (!streamEnd) {
                        done = false;
                    }
                }

                if (done) {
                    break;
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
            Log.e("Fire", "PCM:235行:" + e.toString());
        } finally {
            CloseUtils.closeIOQuietly(audioFileStreams);
            CloseUtils.closeIOQuietly(output, bufferedOutput);
        }

    }
```



