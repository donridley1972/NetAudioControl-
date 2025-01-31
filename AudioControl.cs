﻿using Microsoft.Win32;
using NAudio.Wave;
using NAudio.WaveFormRenderer;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Newtonsoft.Json;
using NAudio.Wave.SampleProviders;
using NAudio.Gui;
using System.Linq.Expressions;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using System.Runtime.Remoting.Messaging;
using System.Security.Cryptography;
//using WaveFormRenderer;

namespace claAudio
{
    [ProgId("ClaAudio")]
    [ClassInterface(ClassInterfaceType.AutoDispatch)]
    [ComSourceInterfaces(typeof(IClaAudioEvents))]
    public partial class AudioControl : UserControl
    {

        private IWavePlayer wavePlayer;
        //private WaveOutEvent outputDevice;
        private DirectSoundOut outputDevice;
        private AudioFileReader audioFileReader;
        private Action<float> setVolumeDelegate;
        private string fileName;
        private string imageFile;
        private string currentPosition;
        private Guid deviceGuid;
        private int sliderPos;
        //private readonly NAudio.WaveFormRenderer.WaveFormRenderer waveFormRenderer;
        //private WaveFormRendererSettings standardSettings;

        public class OutputDevicesData
        {
            public Guid DevideGUID { get; set; }
            public string ModuleName { get; set; }
            public string Description { get; set; }
        }

        protected IList<OutputDevicesData> outputDevicesItems = new BindingList<OutputDevicesData>();
        protected OutputDevicesData selectedDataStructure = null;

        public event OnSendOutputDevice SendOutputDevice;
        public delegate void OnSendOutputDevice(string pGuid,string pModule,string pDescription);

        public event OnSliderUpdate SliderUpdate;
        public delegate void OnSliderUpdate(int pTick);

        public AudioControl()
        {
            InitializeComponent();

            
        }

        //https://pastebin.com/U0MSNY1p
        [ComRegisterFunction]
        private static void ComRegister(Type t)
        {
            string keyName = @"CLSID\" + t.GUID.ToString("B");

            using (RegistryKey key = Registry.ClassesRoot.OpenSubKey(keyName, true))
            {
                if (key == null)
                    return;


                if (key.CreateSubKey("Control") != null) key.CreateSubKey("Control").Close();

                using (RegistryKey subkey = key.CreateSubKey("MiscStatus"))
                {
                    if (subkey != null) subkey.SetValue("", "131457");
                }
                using (RegistryKey subkey = key.CreateSubKey("TypeLib"))
                {
                    Guid libid = Marshal.GetTypeLibGuidForAssembly(t.Assembly);
                    if (subkey != null) subkey.SetValue("", libid.ToString("B"));
                }
                using (RegistryKey subkey = key.CreateSubKey("Version"))
                {
                    Version ver = t.Assembly.GetName().Version;
                    string version = string.Format("{0}.{1}", ver.Major, ver.Minor);

                    if (String.Compare(version, "0.0", false) == 0)

                        version = "1.0";
                    if (subkey != null) subkey.SetValue("", version);
                }
            }
        }

        [ComUnregisterFunction]
        private static void ComUnregister(Type t)
        {
            Registry.ClassesRoot.DeleteSubKeyTree(@"CLSID\" + t.GUID.ToString("B"));
        }

        public void LoadFile(string pPath) {
            Trace.WriteLine("LoadFile[" + String.Concat(pPath) + "]");
            //OpenFileDialog open = new OpenFileDialog();
            //open.Filter = "MP3 Files|*.mp3|WAV files|*.wav";
            //if (open.ShowDialog() != DialogResult.OK) return;
            fileName = pPath; //open.FileName;

            //standardSettings.TopPeakPen.Color = Color.Blue;

        }

        public void Play() {
            if (deviceGuid.ToString() is null) return;


            if (outputDevice == null)
            {
                outputDevice = new DirectSoundOut(deviceGuid);
                outputDevice.PlaybackStopped += OnPlaybackStopped;
            }
            if (audioFileReader == null)
            {
                audioFileReader = new AudioFileReader(fileName);         //(@"D:\example.mp3");
                outputDevice.Init(audioFileReader);
            }

            try
            {
                if (wavePlayer == null) {
                    Trace.WriteLine("Attempting CreateWaveOut");
                    CreateWaveOut();
                }

            }
            catch (Exception driverCreateException)
            {
                MessageBox.Show(String.Format("{0}", driverCreateException.Message));
                return;
            }

            ISampleProvider sampleProvider;
            try
            {
                Trace.WriteLine("Attempting CreateInputStream");
                sampleProvider = CreateInputStream(fileName);
            }
            catch (Exception createException)
            {
                MessageBox.Show(String.Format("{0}", createException.Message), "Error Loading File");
                return;
            }

            try
            {
                Trace.WriteLine("Attempting wavePlayer.Init");
                wavePlayer.Init(sampleProvider);
                // we don't necessarily know the output format until we have initialized
                //textBoxPlaybackFormat.Text = $"{wavePlayer.OutputWaveFormat}";
            }
            catch (Exception initException)
            {
                MessageBox.Show(String.Format("{0}", initException.Message), "Error Initializing Output");
                return;
            }

            if (wavePlayer != null)
            {
                audioFileReader.CurrentTime = TimeSpan.FromSeconds(audioFileReader.TotalTime.TotalSeconds * sliderPos / 100.0);
            }

            outputDevice.Play();
            wavePlayer.Play();
        }

        public void Stop()
        {
            Trace.WriteLine("Stop");
            if (outputDevice != null)
            {
                if (outputDevice.PlaybackState != PlaybackState.Stopped)
                {
                    outputDevice.Stop();
                }
            }
            if (audioFileReader != null)
            {
                //audioFileReader.Dispose();
                //audioFileReader = null;
            }
            if (wavePlayer != null)
            {
                if (wavePlayer.PlaybackState == PlaybackState.Playing)
                {
                    wavePlayer.Pause();
                }

                if (wavePlayer.PlaybackState != PlaybackState.Stopped)
                {
                    //wavePlayer.Stop();
                }
            }
        }

        private ISampleProvider CreateInputStream(string fileName)
        {
            Trace.WriteLine("CreateInputStream");
            audioFileReader = new AudioFileReader(fileName);
            //textBoxCurrentFile.Text = $"{Path.GetFileName(fileName)}\r\n{audioFileReader.WaveFormat}";

            var sampleChannel = new SampleChannel(audioFileReader, true);
            sampleChannel.PreVolumeMeter += OnPreVolumeMeter;
            setVolumeDelegate = vol => sampleChannel.Volume = vol;
            var postVolumeMeter = new MeteringSampleProvider(sampleChannel);
            postVolumeMeter.StreamVolume += OnPostVolumeMeter;

            return postVolumeMeter;
        }

        private void OnPlaybackStopped(object sender, StoppedEventArgs args)
        {
            Trace.WriteLine("OnPlaybackStopped");
            //waveformPainter1.Invalidate();
            //waveformPainter2.Invalidate();
            //waveformPainter1.Refresh();
            //waveformPainter2.Refresh();

            //waveformPainter1.Dispose();
            //waveformPainter2.Dispose();
            //this.waveformPainter1 = new NAudio.Gui.WaveformPainter();
            //this.waveformPainter2 = new NAudio.Gui.WaveformPainter();

            //SetSliderPos(100);
            //if (audioFileReader != null)
            //{
            //    audioFileReader.Position = 0;
            //}

            //if (outputDevice != null)
            //{
            //    outputDevice.Dispose();
            //    outputDevice = null;
            //}
            //if (audioFileReader != null)
            //{
            //    audioFileReader.Position = 0;
            //    audioFileReader.Dispose();
            //    audioFileReader = null;
            //}
            //if (wavePlayer != null)
            //{
            //    wavePlayer.Dispose();
            //    wavePlayer = null;
            //}


        }

        private void CreateDevice()
        {
            wavePlayer = new WaveOut { DesiredLatency = 200 };
        }

        private void CreateWaveOut()
        {
            Trace.WriteLine("CreateWaveOut");

            CloseWaveOut();
            //var latency = (int)comboBoxLatency.SelectedItem;
            //wavePlayer = SelectedOutputDevicePlugin.CreateDevice(latency);
            CreateDevice();
            //wavePlayer = myWavePlayer.CreateDevice(400);
            //wavePlayer.
            wavePlayer.PlaybackStopped += OnPlaybackStopped;
        }

        void OnPreVolumeMeter(object sender, StreamVolumeEventArgs e)
        {
            // we know it is stereo
            TimeSpan currentTime = (wavePlayer.PlaybackState == PlaybackState.Stopped) ? TimeSpan.Zero : audioFileReader.CurrentTime;
            //Trace.WriteLine(Math.Min(100, (int)(100 * currentTime.TotalSeconds / audioFileReader.TotalTime.TotalSeconds)));
            SetSliderPos(Math.Min(100, (int)(100 * currentTime.TotalSeconds / audioFileReader.TotalTime.TotalSeconds)));
            waveformPainter1.AddMax(e.MaxSampleValues[0]);
            waveformPainter2.AddMax(e.MaxSampleValues[1]);
        }

        void OnPostVolumeMeter(object sender, StreamVolumeEventArgs e)
        {
            // we know it is stereo
            volumeMeter1.Amplitude = e.MaxSampleValues[0];
            volumeMeter2.Amplitude = e.MaxSampleValues[1];

            UpdatePosition();
        }

        private void CloseWaveOut()
        {
            Trace.WriteLine("CloseWaveOut");

            if (wavePlayer == null) return;

            if (wavePlayer != null)
            {
                wavePlayer.Stop();
            }
            if (audioFileReader != null)
            {
                // this one really closes the file and ACM conversion
                audioFileReader.Dispose();
                setVolumeDelegate = null;
                audioFileReader = null;
            }
            if (wavePlayer != null)
            {
                wavePlayer.Dispose();
                wavePlayer = null;
            }
        }

        public void GetOutputDevices()
        {
            Trace.WriteLine("GetOutputDevices");

            foreach (var dev in DirectSoundOut.Devices)
            {
                //Trace.WriteLine($"{dev.Guid} {dev.ModuleName} {dev.Description}");
                outputDevicesItems.Add(new OutputDevicesData { DevideGUID = dev.Guid, ModuleName = dev.ModuleName, Description = dev.Description });
                //SendOutputDevice(dev.Guid.ToString(), dev.ModuleName, dev.Description);
                try
                {
                    Invoke((Action)(() => SendOutputDevice(dev.Guid.ToString(), dev.ModuleName, dev.Description)));
                }
                catch (Exception e)
                {
                    Trace.WriteLine(e.GetType().Name + " : " + e.Message);
                }
            }
        }

        public void SetDeviceGuid(string pGuid)
        {
            Trace.WriteLine("SetDeviceGuid[" + String.Concat(pGuid) + "]");
            deviceGuid = new Guid(pGuid);
        }

        public void Kill() {
            Trace.WriteLine("OnPlaybackStopped");
            if (outputDevice != null)
            {
                if (outputDevice.PlaybackState != PlaybackState.Stopped)
                {
                    outputDevice.Stop();
                }
                outputDevice.Dispose();
                outputDevice = null;
            }
            if (audioFileReader != null)
            {
                audioFileReader.Dispose();
                audioFileReader = null;
            }
            if (wavePlayer != null)
            {
                if (wavePlayer.PlaybackState != PlaybackState.Stopped)
                {
                    wavePlayer.Stop();
                }
                wavePlayer.Dispose();
                wavePlayer = null;
            }

            foreach (Control control in this.Controls) {
                if (control != null)
                {
                    Trace.WriteLine("Disposing Control [" + control.Name + "]");
                    control.Dispose();
                }
            }
        }

        private void AudioControl_Resize(object sender, EventArgs e)
        {

            //waveformPainter1.Height = this.Height / 2;
            //waveformPainter2.Height = this.Height / 2;

            int newTop = (waveformPainter1.Top + waveformPainter1.Height) + 5;
            int newWidth = this.Width - (volumeMeter1.Width + volumeMeter2.Width) - 15;

            Trace.WriteLine("AudioControl_Resize " + newTop);
            waveformPainter1.SetBounds(0, 0, newWidth, (this.Height / 2)-5);
            //waveformPainter1.Height = this.Height / 2;
            waveformPainter2.SetBounds(0, newTop, newWidth, (this.Height / 2)-5);

            this.Refresh();
        }

        private void AudioControl_SizeChanged(object sender, EventArgs e)
        {
            Trace.WriteLine("AudioControl_SizeChanged");
        }

        public void SetWaveGraphBackGroundColor(int pRed,int pGreen,int pBlue,int pControl) {
            Trace.WriteLine("SetWaveGraphBackGroundColor-pRed[" + pRed + "]pGreen[" + pGreen + "]pBlue[" + pBlue + "]pControl[" + pControl + "]");
            switch (pControl) { 
            
                case 1:
                    waveformPainter1.BackColor = Color.FromArgb(pRed, pGreen, pBlue); break;
                case 2:
                    waveformPainter2.BackColor = Color.FromArgb(pRed, pGreen, pBlue); break;
            }
        }

        public void SetWaveGraphForeGroundColor(int pRed, int pGreen, int pBlue, int pControl)
        {

            switch (pControl)
            {

                case 1:
                    waveformPainter1.ForeColor = Color.FromArgb(pRed, pGreen, pBlue); break;
                case 2:
                    waveformPainter2.ForeColor = Color.FromArgb(pRed, pGreen, pBlue); break;
            }
        }

        public void SetVolumeMeterForeGroundColor(int pRed, int pGreen, int pBlue, int pControl)
        {

            switch (pControl)
            {
                
                case 1:
                    volumeMeter1.ForeColor = Color.FromArgb(pRed, pGreen, pBlue); break;
                case 2:
                    volumeMeter2.ForeColor = Color.FromArgb(pRed, pGreen, pBlue); break;
            }
        }

        public string GetFileFormat() {

            Trace.WriteLine("claAudio - GetFileFormat " + wavePlayer.OutputWaveFormat.ToString());
            return wavePlayer.OutputWaveFormat.ToString();
            //return $"{wavePlayer.OutputWaveFormat}";
        }

        private void OnTimerTick(object sender, EventArgs e)
        {
            if (audioFileReader != null)
            {
                UpdatePosition();
            }
        }

        public void UpdatePosition()
        {
            currentPosition = string.Format("{0}/{1}", audioFileReader.CurrentTime, audioFileReader.TotalTime);
            //labelPosition.Text = string.Format("{0}/{1}", audioFileReader.CurrentTime, audioFileReader.TotalTime);
            //trackBar1.Value = Math.Min((int)((trackBar1.Maximum * reader.Position) / reader.Length), trackBar1.Maximum);
        }

        public string GetPosition() { 
            return currentPosition;
        }

        public int GetSliderPos() { 
            return sliderPos;
        }

        private void SetSliderPos(int pos)
        {
            sliderPos = pos;
        }

        public void SetAudioPosition(int pSliderPos) {

            Trace.WriteLine("SetAudioPosition");

            if (wavePlayer != null)
            {
                sliderPos = pSliderPos;
                audioFileReader.CurrentTime = TimeSpan.FromSeconds(audioFileReader.TotalTime.TotalSeconds * pSliderPos / 100.0);
            }
        }

        public void SetVolume(float pVolume) {

            Trace.WriteLine("SetVolume-pVolume[" + pVolume + "]");

            setVolumeDelegate(pVolume);

        }
    }
}
