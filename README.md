# Smart TV - Smart Display Exfiltration

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)
![Python Version](https://img.shields.io/badge/python-3%2B-blue.svg)
![Flutter Version](https://img.shields.io/badge/flutter-3.0%2B-blue.svg)
![Android API](https://img.shields.io/badge/Android-API%2028+-yellow.svg)

## Overview

This repository contains the project associated with the thesis titled **"Smart TV - Smart Display Exfiltration"**, developed as part of the Master's in Cybersecurity at **Universidad Católica de Murcia (UCAM) and Campus Internacional de Ciberseguridad**. The project investigates the covert exfiltration of data using **Smart TVs** as transmitters and **camera-equipped devices** as receivers. By utilizing **visual steganography**, this project demonstrates how sensitive information can be communicated discreetly and without detection by traditional security systems.

## Table of Contents

- [Key Features](#key-features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation Guide](#installation-guide)
- [Running the Saturation Script](#running-the-saturation-script)
- [Setting Up the Transmitter (Smart TV)](#setting-up-the-transmitter-smart-tv)
- [Setting Up the Receiver](#setting-up-the-receiver)
- [Usage](#usage)
- [Video Demonstration](#video-demonstration)
- [Contribution](#contribution)
- [Project History](#project-history)
- [Contact](#contact)

## Key Features

- **Smart TV Transmitter Application:** An Android TV application that dynamically overlays a watermark on the screen, encoding binary data through varying saturation levels.
- **Receiver Application:** Flutter-based cross-platform app that captures and decodes the transmitted visual data using a camera.
- **Saturation Script:** Python script used to preprocess watermark images by adjusting saturation levels for efficient data transmission.
- **Data Exfiltration Mechanism:** Demonstrates data transmission between isolated devices, avoiding traditional network communication.

## Project Structure

```bash
├── smart_tv_emitter/               # Source code for the Smart TV transmitter app
├── cam_receiver/                   # Source code for the receiver app
└── stego_script/                   # Python script for image saturation adjustments
```

## Prerequisites

Before running the project, ensure you have the following items:

- **Python 3+** (for running the saturation script)
- **Android Studio** (for building the Smart TV transmitter app)
- **Flutter SDK** (for building the receiver app)
- **Compatible Android TV** (for running the transmitter app)
- **A camera-equipped device** (e.g., Android device, iPhone, tablet) for running the receiver app

## Installation Guide

### 1. Clone the Repository

```bash
git clone https://github.com/DevJoseEstrada/SmartTV-StegoExfiltration.git
cd SmartTV-StegoExfiltration
```

### 2. Install Python Dependencies

Navigate to the `stego_script/` directory and install the necessary Python packages:

```bash
pip install -r requirements.txt
```

Dependencies include:
- `numpy==2.0.0`
- `opencv-python==4.10.0.84`

## Running the Saturation Script

The `script.py` script adjusts the saturation of images that will be used as watermarks during data transmission:

```bash
python3 script.py path/to/image.png 10
```

This will generate three images with different saturation levels:

- **base.png** – base image
- **base0.png** – reduced saturation
- **base1.png** – increased saturation

Place these images in the `res/drawable/` directory of the **smart_tv_emitter** project for the next step.

## Setting Up the Transmitter (Smart TV)

1. **Open the Transmitter Project:**
   - Open the `smart_tv_emitter/` project in **Android Studio**.

2. **Insert Watermark Images:**
   - Ensure that the `base.png`, `base0.png`, and `base1.png` images generated from the saturation script are placed in the `res/drawable/` directory.

3. **Configure Transmission Parameters:**
   - Edit the `build.gradle.kts` file and add/modify the following parameters:

   ```kotlin
   buildConfigField("long", "TIME_SHOW_IMG_MOD_MS", "150")
   buildConfigField("long", "FREQUENCY_MS", "1000")
   ```

   - **TIME_SHOW_IMG_MOD_MS**: Time (in milliseconds) to display each modified image.
   - **FREQUENCY_MS**: Interval between each transmission (in milliseconds).

4. **Build & Run:**
   - Build the project and deploy it on a **Smart TV emulator** or a **physical Android TV**.

5. **Permissions:**
   - Ensure the app has **overlay permissions** to display the watermark on the screen.

## Setting Up the Receiver

1. **Deploy the Receiver:**
   - Open the `cam_receiver/` project in **Visual Studio Code** with Flutter support.
   - Deploy the app on any camera-equipped device (e.g., Android device, iPhone, or tablet).

## Usage

### 1. **Start the Transmitter:**
   Ensure the Smart TV app is running and the watermark is displayed correctly.

### 2. **Start the Receiver:**

1. **Align the Camera:**
   - Launch the receiver application on your camera-equipped device.
   - Point the device's camera at the Smart TV screen to begin the capture process.

2. **Configure the Settings:**
   - Once the receiver app is running and aligned with the screen, you can optimize the data capture process by adjusting the following settings directly from the app’s **UI**:

   | Setting                           | Description                                                                                  |
   |-----------------------------------|----------------------------------------------------------------------------------------------|
   | Milliseconds Showing Modified Img | Sets the duration (in milliseconds) that each modified image is displayed on the screen.      |
   | Frequency in milliseconds         | Adjusts the interval (in milliseconds) between each data transmission.                        |
   | Percentage Difference Threshold   | Defines the threshold percentage difference that triggers the detection of data transmission. |
   | Number of Cycles                  | Specifies the number of cycles the data transmission process will undergo.                    |
   | Zoom Level (Slider)               | Enables zoom adjustment to focus the camera on the watermark for optimal capture.             |

3. **Start the Decoding Process:**
   - After configuring the settings, initiate the decoding process. The receiver app will begin capturing the data transmitted from the Smart TV and will decode it in real time based on the configured parameters.

### 3. **Monitor Transmission:**
   The binary data will be displayed on the device in real time. Once all the required cycles have been captured, the data will be decoded into ASCII. If any errors occur during the process, they will also be displayed.

## Video Demonstration

Watch the complete system in action by clicking on the image below:

[![Watch the video](https://img.youtube.com/vi/vH0G5Nh_Lm4/0.jpg)](https://youtu.be/vH0G5Nh_Lm4)

*This video demonstrates the entire process, from setting up the transmitter and receiver to successfully decoding the transmitted data.*

## Contribution

This project is part of an academic exercise in **cybersecurity research**. While direct contributions to this repository are closed, I would be thrilled to see this Proof of Concept (PoC) used in other projects or research endeavors. If you wish to build upon this work, adapt it, or reference it in your own research, please feel free to do so. Acknowledging this work in your projects would be greatly appreciated, and I would love to hear about how it's being applied or extended in different contexts.

If you have any questions or want to discuss further collaboration, feel free to reach out!

## Project History

- **Project Initiation:** April 2024
- **Completion:** August 2024

## Contact

For inquiries, feel free to contact:

- **José Manuel Estrada Rodríguez**
- **Email:** devjmestrada@gmail.com

Thank you for exploring this project!
