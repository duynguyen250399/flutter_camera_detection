#include <opencv2/opencv.hpp>
#include <iostream>

using namespace cv;

extern "C" {

    __attribute__((visibility("default"))) __attribute__((used))
	const char* version() {
		return CV_VERSION;
	}

    __attribute__((visibility("default"))) __attribute__((used))
	const int cameraBrightness(int width, int height, uint8_t* bytes, bool isYUV) {
		Mat frame;

		if(isYUV){
			Mat myyuv(height + height / 2, width, CV_8UC1, bytes);
			cvtColor(myyuv, frame, COLOR_YUV2BGRA_NV21);
		}
		else {
			frame = Mat(height, width, CV_8UC4, bytes);
		}


		Mat hsv;

		cvtColor(frame, hsv, COLOR_BGR2HSV);

		Scalar result = mean(frame);
		int brightness = result[2];
		
		return brightness;
	}

	__attribute__((visibility("default"))) __attribute__((used))
	const double cameraBlurry(int width, int height, uint8_t* bytes, bool isYUV) {
		Mat frame;

		if(isYUV){
			Mat myyuv(height + height / 2, width, CV_8UC1, bytes);
			cvtColor(myyuv, frame, COLOR_YUV2BGRA_NV21);
		}
		else {
			frame = Mat(height, width, CV_8UC4, bytes);
		}

		Mat gray, laplacian;

		cvtColor(frame, gray, COLOR_BGR2GRAY);
		Laplacian(gray, laplacian, CV_64F);

		Scalar mean, stddev;

		meanStdDev(laplacian, mean, stddev, Mat());

		double blurryVariance = stddev.val[0] * stddev.val[0];

		return blurryVariance;
	}

}