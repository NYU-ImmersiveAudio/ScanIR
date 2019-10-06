# ScanIR v2.1
Impulse Response measurement tool for MATLAB.

ScanIR is available through CreativeCommons License.

### Publications
When using the tool please mention the following publications

Vanasse, J., Genovese, A. & Roginska, A. (2019, March). [Multichannel impulse response measurement in matlab: An update on ScanIR](https://andreagenovese.com/wp-content/uploads/2019/07/EBrief1___ScanIR-2.pdf). In Audio Engineering Society, Interactive and Immersive Audio Conference, York 2019. 

Boren, B., & Roginska, A. (2011, October). [Multichannel impulse response measurement in matlab](https://www.researchgate.net/publication/265876631_Multichannel_Impulse_Response_Measurement_in_Matlab). In Audio Engineering Society Convention 131. Audio Engineering Society.

### Description

ScanIR is an impulse response measurement tool written for MATLAB which streamlines the process of generating, emitting and recording an acoustic measurement signal. Several types of measurement signals and recording settings are available for the measurement of Room-Impulse-Responses, Multichannel-Impulse-Responses, Head-Related-Impulse-Responses and others. The program intends to simplify the measurement process and provides the experimenter with the acoustic response data in customizable format. 

### Changelog

ScanIR v2.1:
- Can now select separate Input/Output interfaces (if sample-rate is compatible)
- Various bug fixes for MLS and Golay playback
- Minor Adjustments to the GUI interface
- Excitation level control

**IMPORTANT: Due to limitations of PsychPortAudio, it is not possible to change the device sample rate within ScanIR as it now uses separate I/O controls. Please set your I/P and O/P devices sample rates from your computer settings, then restart MATLAB**

ScanIR v2.0:
-  Redesigned interface
-  Tested on MacOS and Windows
-  Added BRIR option
-  SOFA output file format available
-  ARDUINO UNO step motor feature integration
-  Step motor speed and rotation settings
-  Drop-down interface selection
-  Updated plotting tools
-  EDC plots
-  Optional raw IR preservation
-  Various RIR/HRIR Analysis metrics (multi-channel or single-channel)
-  Minor bug fixes

ScanIRv2 has been extensively tested on MacOS Sierra and Windows 10. The use of other operating systems may lead to possible problems. Please report any bugs found or desired features. 

### Installation Requirements 
To run ScanIR you will **need** the following software
-  MATLAB version 2016a or higher https://www.mathworks.com/
-  Psychtoolbox-3 http://psychtoolbox.org/ 

Rotating Motor Feature (Optional): 
-  ARDUINO Matlab package https://www.mathworks.com/hardware-support/arduino-matlab.html
-  ARDUINO IDE

Enhanced analysis metrics (Optional):
-  Matlab Signal Processing Toolbox

Minimum Operating System:
-  Windows Vista or newer
-  MacOS El Capitan or newer

### Setup
Once all required components are installed just download the git and open the folder through MATLAB. To run ScanIR, click on the file ScanIR.m and run the script to start the GUI. When using external audio cards to connect microphone and loudspeakers please connect them prior to starting MATLAB. At the present moment, the same device needs to be used for input and output.

### Hardware required for step-motor system
-  [ARDUINO UNO microcontroller](https://store.arduino.cc/arduino-uno-rev3)
-  [ADAFRUIT stepper shield](https://www.adafruit.com/product/1438)

Any compatible step motor of desired resolution should work with the system. The following has been tested in previous works (see other references)
-  Suggested: [Step motor NEMA23 3A](https://www.automationtechnologiesinc.com/products-page/stepper-motors/nema-23-bipolar-stepper-motor-156-oz-in-%C2%BC%E2%80%9D-dual-shaft-with-a-flat/)

### Usage 
Please refer to the full user manual pdf for learning the full capabilities and features of the tool.

### Contributors

**NYU Music and Audio Research Lab:**  
Braxton Boren  
Andrea Genovese  
Agnieszka Roginska  
Charlie Mydlarz  
Julian Vanasse  
Gabriel Zalles  
Cindy Bui  
Frederick Scott  

**Other Contributors (GitHub)**  
JP-Lisn

### See Also
ScanIR v2 has been used for the following studies:

Zalles, G., Kamel, Y., Anderson, I., Lee, M. Y., Neil, C., Henry, M., ... & Roginska, A. (2017, October). [A Low-Cost, High-Quality MEMS Ambisonic Microphone](https://s18798.pcdn.co/immersiveaudiogroup/wp-content/uploads/sites/7671/2017/10/Zalles_MEMS.pdf). In Audio Engineering Society Convention 143. Audio Engineering Society.

Genovese, A., Zalles, G., Reardon, G., & Roginska, A. (2018, August). [Acoustic perturbations in HRTFs measured on Mixed Reality Headsets](https://s18798.pcdn.co/immersiveaudiogroup/wp-content/uploads/sites/7671/2018/09/Acoustical_distortions_from_Augment_Reality_devices.pdf). In Audio Engineering Society Conference: 2018 AES International Conference on Audio for Virtual and Augmented Reality. Audio Engineering Society.

 
