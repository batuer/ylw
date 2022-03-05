title:  AsyncTask
date: 2018年3月23日08:25:12
categories: AsyncTask
tags: 

	 - Android
	 - AsyncTask
cover_picture: /images/common.png
---

### AsyncTask

- AsyncTask 是 Android 中一个异步处理的框架，它内部集成了线程池和 Handler 机制，实现了异步任务加载和主线程更新 UI 的功能，在 Android 中不同的版本的 AsyncTask 却有点不一样。
- Android中工作者线程主要有AsyncTask、IntentService、HandlerThread，它们本事上都是对线程或线程池的封装。(ThreadPoolExecutor)

#### 使用简介

- AsyncTask是对Handler与线程池的封装。AsyncTask内部包含一个Handler，方便更新UI。使用线程池
- onPreExecute() //此方法会在后台任务执行前被调用，用于进行一些准备工作 
- doInBackground(Params… params) //此方法中定义要执行的后台任务，在这个方法中可以调用publishProgress来更新任务进度（publishProgress内部会调用onProgressUpdate方法） 
- onProgressUpdate(Progress… values) //由publishProgress内部调用，表示任务进度更新 
- onPostExecute(Result result) //后台任务执行完毕后，此方法会被调用，参数即为后台任务的返回结果 
- onCancelled() //此方法会在后台任务被取消时被调用
- 以上方法中，除了doInBackground方法由AsyncTask内部线程池执行外，其余方法均在主线程中执行。

#### 局限性

- Android4.1之前AsyncTask类必须在主线程中加载。
- 在Android 4.1以及以上版本则不存在这一限制，因为ActivityThread（代表了主线程）的main方法中会自动加载AsyncTask 。
- 一个AsyncTask对象只能调用一次execute方法。

