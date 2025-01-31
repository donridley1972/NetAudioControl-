#TEMPLATE(dwrNetAudioControl,'.NET Audio Control'),FAMILY('ABC')
#Include('cape01.tpw')
#Include('cape02.tpw')
#INCLUDE('SVFnGrp.TPW')
#INCLUDE('ABOOP.tpw')
#!------------------------------------------------------------------------------------------------------------------------
#Extension(Activate_DwrNetAudioControl,'Activate .NET Audio Control - Version:1.0'),Application
#PREPARE
#ENDPREPARE
#Sheet
    #Tab('General')
        #!#Insert(%GeneralLogoHeader)
        #Boxed(' Debugging '),section,at(,,,28)
            #Prompt('Disable All Template Features',Check),%NoDwrNetAudioControl,At(10,4)
        #EndBoxed
    #EndTab
    #TAB('Classes')
      #Insert(%GlobalDeclareClassesPR)
    #ENDTAB
#ENDSHEET	
#!-----------------------------------------------------------------------------------
#ATStart
  #IF(%NoDwrNetAudioControl=0)
    #INSERT(%ReadGlobal,2,0)
  #ENDIF
#ENDAT
#!-----------------------------------------------------------------------------------
#!#AT(%CustomGlobalDeclarations),where(%NoDwrNetAudioControl=0)
#!#PROJECT('None(claAudio.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.Asio.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.Core.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.Midi.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.Wasapi.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.WaveFormRenderer.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.WinForms.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(NAudio.WinMM.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(Newtonsoft.Json.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(claAudio.manifest), CopyToOutputDirectory=Always')
#!#ENDAT
#!
#!-----------------------------------------------------------------------------------
#AT(%AfterGlobalIncludes)
  Include('dwrAudioControl.inc'),Once
#ENDAT
#!-----------------------------------------------------------------------------------
#AT(%GlobalData)
#ENDAT
#!---------------------------------------------------
#AT(%ShipList)
  #IF(%ApplicationLocalLibrary)
  #ELSE
    #IF(%Target32)
___     claAudio.dll
___     NAudio.Asio.dll
___     NAudio.Core.dll
___     NAudio.dll
___     NAudio.Midi.dll
___     NAudio.Wasapi.dll
___     NAudio.WaveFormRenderer.dll
___     NAudio.WinForms.dll
___     NAudio.WinMM.dll
___     Newtonsoft.Json.dll
    #ENDIF
  #ENDIF
#ENDAT
#!-----------------------------------------------------------------------------------
#AtEnd
  #IF(%NoDwrNetAudioControl = 0)
    #INSERT(%EndGlobal)
  #ENDIF
#ENDAt
#!-------------------------------------------------------------------------------------------------------------------------
#CONTROL(DwrAudioOLEControl,'DWR Audio OLE/OCX'),DESCRIPTION('DWR Audio OLE/OCX(' & INSTANCE(%ActiveTemplateInstance) & ')'),Procedure,SINGLE,req(Activate_DwrNetAudioControl)    #!,DESCRIPTION('DWR Audio OLE/OCX(' & INSTANCE(%ActiveTemplateInstance) & ')'),MULTI    #!,req(Activate_DwrNetAudioControl)   #!,HLP('~TPLControlOLEControl.htm'),WRAP(OLE) ,WINDOW,WRAP(OLE)
  CONTROLS
    Group,AT(,,451,141),USE(?SettingsSheet),Boxed
        PROMPT('Audio File:'),AT(,,,),USE(?AudioFile:Prompt),TRN
        ENTRY(@s255),AT(,,187,10),USE(AudioFile)
        BUTTON('...'),AT(,,12,12),USE(?LookupAudioFile)
        PROMPT('Audio Devices:'),AT(,,,),USE(?AudioDevicesPrompt),TRN
        LIST,AT(,,202,10),USE(LastDeviceGuid),DROP(10),FORMAT('1020L(2)M@s255@#3#')
        BUTTON('Play'),AT(,,,),USE(?PlayBtn)
        OLE,AT(,,441,77),USE(?OLE)
        END
    END
  END
#Sheet
    #TAB('General')
        #ENABLE(%ProgramExtension = 'EXE'),CLEAR
            #PROMPT('Enable Registration-Free Activation ', CHECK),%dwrAudioAddDependency,DEFAULT(1),AT(10)
            #PROMPT('Link manifest', CHECK),%dwrAudioLinkManifest,DEFAULT(1),AT(10)
            #PROMPT('Copy DLL to output folder', CHECK),%dwrAudioCopyToOutput,DEFAULT(1),AT(10)
        #ENDENABLE
          #BOXED('Callback Generation')
            #Prompt('Disable Template',Check),%NoDwrNetAudioControlLocal,At(10)
            #PROMPT('&Event Handler',CHECK),%GenerateEventCallback,default(1),At(10)
            #DISPLAY('Callback procedures will be generated in the procedure''s module.'),At(10)
            #DISPLAY('NOTE: Callback procedures do NOT have access to this procedure''s data!'),At(10)
            #ENABLE(%GenerateEventCallback) #! OR %GenerateChangeCallback OR %GenerateEditCallback)
              #PROMPT('&Include OCX.CLW in global MAP',CHECK),%IncludeOCXMap,DEFAULT(1),At(10)
            #ENDENABLE
          #PROMPT('I&nclude OCXEVENT.CLW in global data section',CHECK),%IncludeOCXEvent,DEFAULT(1),At(10)
          #PROMPT('OLE &BLOB Field',FIELD),%OLEBlobField
        #ENDBOXED
    #ENDTAB
    #TAB('Classes')
      #Boxed(''),section,at(,,,45)
        #Prompt('Object name:',@s255),%rasObjectName,default('myAudio' & %ActiveTemplateInstance),at(50,5,110,),promptat(10,5)
        #Prompt('Class name:',@s255),%rasClassName,default('dwrAudioControl'),at(50,20,110,),promptat(10,20)
      #EndBoxed
      #PROMPT('Declaration Class Embeds',EMBEDBUTTON(%ERSHDeclaration,%ActiveTemplateInstance)),AT(10,,180)
      #PROMPT('Class Embeds',EMBEDBUTTON(%ERSHProcedures,%ActiveTemplateInstance)),AT(10,,180)
      #PROMPT('Lookup Class:',@s20),%dwrLookupClass,DEFAULT('FileLookup' & %ActiveTemplateInstance),at(50,,110,),promptat(10,)
    #ENDTAB
    #TAB('Hidden'),WHERE(%False)
        #PROMPT('Template version:', @s10),%dwrAudioTPLVersion,DEFAULT('1.00')
        #PROMPT('Assembly name:', @s20), %dwrAudioAssemblyName,DEFAULT('claAudio')
        #PROMPT('Assembly version:', @s16),%dwrAudioAssemblyVersion,DEFAULT('1.0.0.0')
    #ENDTAB
#ENDSHEET
#!---------------------------------------------------
#ATSTART
#!#INSERT(%ReadGlobal,3,0)
#insert(%AtStartInitialisation)
#insert(%AddObjectPR,%rasClassName,%rasObjectName,'Local Objects')
  #DECLARE(%OLEControl)
  #DECLARE(%OLEShortName)
  #FOR(%Control),WHERE(%ControlInstance=%ActiveTemplateInstance) #! And %ControlType='OLE')
    #SET(%OLEControl,%Control)
  #ENDFOR
  #SET(%OLEShortName,SUB(%OLEControl,2,LEN(%OLEControl)-1))
#ENDAT
#!---------------------------------------------------
#AT(%CustomGlobalDeclarations),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0)
  #IF(%GenerateEventCallback) #! OR %GenerateChangeCallback OR %GenerateEditCallback)
    #IF(%IncludeOCXMap)
      #ADD(%CustomGlobalMapIncludes,'OCX.CLW')
    #ENDIF
  #ENDIF
  #IF(%IncludeOCXEvent)
    #ADD(%CustomGlobalDeclarationIncludes,'OCXEVENT.CLW')
  #ENDIF
#IF(%dwrAudioCopyToOutput=1)
#PROJECT('None(claAudio.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.Asio.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.Core.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.Midi.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.Wasapi.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.WaveFormRenderer.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.WinForms.dll), CopyToOutputDirectory=Always')
#PROJECT('None(NAudio.WinMM.dll), CopyToOutputDirectory=Always')
#PROJECT('None(Newtonsoft.Json.dll), CopyToOutputDirectory=Always')
#!#PROJECT('None(claAudio.manifest), CopyToOutputDirectory=Always')
#ENDIF
#ENDAT
#!--------------------------------------------------------------------
#AT(%GlobalData),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(4000)
AudioDevices    &AudioDevicesQType
#ENDAT
#!--------------------------------------------------------------------
#AT(%ProgramSetup),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(4000)
AudioDevices &= NEW AudioDevicesQType
#ENDAT
#!--------------------------------------------------------------------
#AT(%DataSection),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(3000)
LastDeviceGuid       STRING(50)
AudioFile            CSTRING(255)
#ENDAT
#!--------------------------------------------------------------------
#AT(%LocalDataClasses),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0)
#INSERT(%GenerateClassDeclaration,%rasClassName,%rasObjectName,'Local Objects','Ridley Objects')
#ENDAT
#!--------------------------------------------------------------------
#AT(%LocalProcedures),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0)
#INSERT(%GenerateMethods,%rasclassname,%rasObjectName,'Local Objects','Ridley Objects')
#ENDAT
#! --------------------------------------------------------------------------
#AT(%LocalDataAfterClasses),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(5000)
%dwrLookupClass     SelectFileClass
#ENDAT
#!--------------------------------------------------------------------
#AT(%dMethodCodeSection,%ActiveTemplate & %ActiveTemplateInstance,%eMethodID),priority(5000),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),DESCRIPTION('Parent Call')
#INSERT(%ParentCall)
  #IF(not VarExists(%tmn))
    #DECLARE(%tmn)
  #ENDIF
  #SET(%tmn,%GetMethodName(%eMethodID))  #! EasyResizeAndSplit backwards compatibility
  #IF(Not (%tmn='Init' and %eMethodPrototype <> '(),VIRTUAL'))
  #EMBED(%ERSProcedures,'DwrTreeControl'),%tmn,'CODE',TREE(%rasObjectName & '|' & %tmn & ' ' & %eMethodPrototype),LEGACY
  #ENDIF
#ENDAT
#!---------------------------------------------------
#AT(%CustomModuleDeclarations),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0)
  #DECLARE(%TempOLEName)
  #FOR(%Control),WHERE(%ControlInstance=%ActiveTemplateInstance)
    #SET(%ValueConstruct,%Control)
  #ENDFOR
  #SET(%TempOLEName,SUB(%ValueConstruct,2,LEN(%ValueConstruct)-1))
  #IF(%GenerateEventCallback)
    #ADD(%CustomModuleMapModule,'CURRENT MODULE')
    #SET(%ValueConstruct,%Procedure & %TempOLEName & 'EventHandler')
    #ADD(%CustomModuleMapProcedure,%ValueConstruct)
    #SET(%CustomModuleMapProcedurePrototype,'PROCEDURE(*SHORT ref,SIGNED OLEControlFEQ,LONG OLEEvent),LONG')
  #ENDIF
#ENDAT
#!---------------------------------------------------
#AT(%AfterWindowOpening),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0)
#EMBED(%BeforeOLEInitialization,'Before initializing Audio OLE/OCX control'),%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
  #IF(%OLEBlobField)
IF %OLEBlobField{PROP:size} > 0
  #EMBED(%BeforeAssignToOLE,'Before assigning BLOB to Audio OLE/OCX Control'),WHERE(%OLEBlobField),%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
  %OLEControl{PROP:Blob} = %OLEBlobField{PROP:handle}
  #EMBED(%AfterAssignToOLE,'After assigning BLOB to OLE Control'),WHERE(%OLEBlobField),%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
    #SUSPEND
#?ELSE
  #EMBED(%NoBlobContents,'When the Audio OLE/OCX Blob is Empty'),WHERE(%OLEBlobField),%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
    #RESUME
END
  #ENDIF
  #IF(%GenerateEventCallback)
    #SET(%ValueConstruct,%Procedure & %OLEShortName & 'EventHandler')
OCXRegisterEventProc(%OLEControl,%ValueConstruct)
  #ENDIF
#EMBED(%AfterOLEInitialization,'After initializing Audio OLE/OCX control'),%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
#ENDAT
#!---------------------------------------------------
#AT(%ControlOtherEventHandling,%OLEControl),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0)
  #SUSPEND
#?IF EVENT()=EVENT:Accepted
  #EMBED(%BeforeBlobAssign,'Before assigning from Audio OLE/OCX control to BLOB'),WHERE(%OLEBlobField),%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
    #IF(%OLEBlobField)
  %OLEBlobField{PROP:handle} = %OLEControl{PROP:Blob}
    #ENDIF
  #EMBED(%AfterBlobAssign,'After assigning from Audio OLE/OCX control to BLOB'),WHERE(%OLEBlobField),%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
#?END
  #RESUME
#ENDAT
#!---------------------------------------------------
#AT(%LocalProcedures),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0)
  #IF(%GenerateEventCallback)
    #SET(%ValueConstruct,%Procedure & %OLEShortName & 'EventHandler')
#!---------------------------------------------------
%ValueConstruct FUNCTION(*SHORT ref,SIGNED OLEControlFEQ,LONG OLEEvent)
#EMBED(%EventHandlerDeclaration,'Audio OLE/OCX Event Handler, Declaration Section'),DATA,%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
  CODE
#EMBED(%EventHandlerCode,'Audio OLE/OCX Event Handler, Code Section'),LABEL,%ActiveTemplateInstance,MAP(%ActiveTemplateInstance,%ActivetemplateInstanceDescription)
  RETURN(True)
  #ENDIF
#ENDAT
#!---------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(8080)
#FOR(%Control),WHERE(%ControlType='OLE')
#SET(%OLEControl,%Control)
#ENDFOR
%rasObjectName.CreateOLE(%OLEControl)
#ENDAT
#!---------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(9500)
%rasObjectName.GetOutputDevices()
#ENDAT
#!---------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(9950)
If AudioFile  
  #!?OLE{'LoadFile(' & AudioFile & ')'}
  %rasObjectName.LoadFile(AudioFile)
End
If LastDeviceGuid
  %rasObjectName.SetDeviceGuid(LastDeviceGuid)
End
#ENDAT
#!---------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(9980)
?LastDeviceGuid{PROP:From} = AudioDevices
#ENDAT
#! --------------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(8440)
%dwrLookupClass.Init
%dwrLookupClass.ClearOnCancel = True
%dwrLookupClass.Flags=BOR(%dwrLookupClass.Flags,FILE:LongName)   ! Allow long filenames
%dwrLookupClass.SetMask('Audio Files','*.wav;*.mp3')         ! Set the file mask
#ENDAT
#! --------------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Open','()'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(500)
#!%rasObjectName.CreateOLE(%OLEControl)
#ENDAT
#! --------------------------------------------------------------------------
#AT(%ControlEventHandling,'?LookupAudioFile','Accepted'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(8500)
ThisWindow.Update()
AudioFile = %dwrLookupClass.Ask(1)
DISPLAY
%rasObjectName.LoadFile(AudioFile)
#ENDAT
#!------------------------------------------------------------------------------
#AT(%EventHandlerCode,%ActiveTemplateInstance),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(5000)
  If OcxGetParamCount(ref)
    Case OLEEvent 
    Of 301
#EMBED(%dwrAudoOLEEventHandlerEvent301,'AudoControl OLE EventHandler - Event 301')  #!,TREE('DwrTreeControl' & %ActiveTemplateInstance & '|TreeControl Primary View Next'),%dwrPrimaryTreeFiles
      AudioDevices.DevideGUID = OcxGetParam(ref, 1)
      Get(AudioDevices,AudioDevices.DevideGUID)
      If Errorcode()
        AudioDevices.ModuleName = OcxGetParam(ref, 2)
        AudioDevices.Description = OcxGetParam(ref, 3)
        Add(AudioDevices)
      End
    Of 302
#EMBED(%dwrAudoOLEEventHandlerEvent302,'AudoControl OLE EventHandler - Event 302')
    #!PROP:sliderpos
    End 
  End
#ENDAT
#!------------------------------------------------------------------------------
#AT(%ControlEventHandling,'?LastDeviceGuid','Accepted'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(5000)
%rasObjectName.SetDeviceGuid(LastDeviceGuid)
#ENDAT
#!------------------------------------------------------------------------------
#AT(%ControlEventHandling,'?PlayBtn','Accepted'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(8500)
?PlayBtn{PROP:Text} = CHOOSE(?PlayBtn{PROP:Text}='Play','Stop','Play')
Case %rasObjectName.GetIsPlaying()
Of False 
  0{PROP:Timer} = 100
  %rasObjectName.Play()
Of True
  0{PROP:Timer} = 0
  %rasObjectName.Stop()
End
#ENDAT
#!------------------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'TakeEvent','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(3200)
#ENDAT
#!---------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Kill','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),Priority(2300)
Dispose(AudioDevices)
%rasObjectName.Kill()
#ENDAT
#! --------------------------------------------------------------------------
#AT(%AfterGeneratedApplication)
#IF(NOT VAREXISTS(%pDllManifestFile))
    #DECLARE(%pDllManifestFile)
#ENDIF
#!#IF(%CWVersion > 8000)
#IF(%GenerateXPManifest=1)
    #IF(%dwrAudioAddDependency = '1')
        #CALL(%dwrAddDependency, %dwrAudioAssemblyName, %dwrAudioAssemblyVersion, %dwrAudioLinkManifest)
        #CALL(%dwrCreateDLLManifest)
    #ENDIF
#ENDIF
#!#ENDIF
#ENDAT
#!-------------------------------------------------------------------------------------------------------------------------
#CONTROL(DwrAudioPanSlider,'DWR Audio Pan Slider'),DESCRIPTION('DWR Audio Pan Slider(' & INSTANCE(%ActiveTemplateInstance) & ')'),Procedure,SINGLE,req(DwrAudioOLEControl)
  CONTROLS
    SLIDER,AT(,,,17),USE(?PanSlider),IMM,RANGE(0,100),STEP(1),BELOW,TRN
  END
#!--------------------------------------------------------------------
#AT(%DataSection),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(3000)
SliderPos            LONG 
SliderSelected       BYTE
#ENDAT
#!--------------------------------------------------------------------
#AT(%ControlEventHandling,'?PanSlider','Accepted'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(8500)
%rasObjectName.SetAudioPosition(?PanSlider{PROP:SliderPos})
SliderSelected = False
#ENDAT
#!--------------------------------------------------------------------
#AT(%ControlEventHandling,'?PanSlider','NewSelection'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(5000)
SliderSelected = True
#ENDAT
#!--------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'TakeEvent','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(5000)
Case EVENT()
Of EVENT:Timer
  If SliderPos = 100
      %rasObjectName.SetIsPlaying(False)
      ?PlayBtn{PROP:Text} = 'Play'
  End
  SliderPos = %rasObjectName.GetSliderPos()
  If Not SliderSelected
      ?PanSlider{PROP:SliderPos} = SliderPos
  End
#EMBED(%dwrAudoTakeEventAfterSlider,'AudoControl TakeEventAfterSlider')
End
#ENDAT
#!-------------------------------------------------------------------------------------------------------------------------
#CONTROL(DwrAudioVolumeSlider,'DWR Audio Volume Slider'),DESCRIPTION('DWR Audio Volume Slider(' & INSTANCE(%ActiveTemplateInstance) & ')'),Procedure,SINGLE,req(DwrAudioOLEControl)
#PREPARE
#!#IF(NOT VAREXISTS(%VolumePcntStr))
#!    #DECLARE(%VolumePcntStr)
#!#ENDIF
#ENDPREPARE
  CONTROLS
    PROMPT('Volume:'),AT(,,27,10),USE(?VolumePrompt),TRN
    SLIDER,AT(,,,17),USE(AudioVolume),RANGE(0,1000),STEP(100),TRN
    STRING('VolumePcntStr'),AT(,,49,10),USE(?VolumePcntStr),TRN
  END
#! --------------------------------------------------------------------------
#ATSTART
#ENDAT
#!--------------------------------------------------------------------
#AT(%DataSection),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(3000)
AudioVolume          REAL(1000) 
#ENDAT
#!--------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(9990)
#DECLARE(%VolumePcntStrPropText)
#SET(%VolumePcntStrPropText,'<39>100 %<39>')
?VolumePcntStr{PROP:Text} = %VolumePcntStrPropText
#ENDAT
#!--------------------------------------------------------------------
#AT(%ControlEventHandling,'?AudioVolume','Accepted'),WHERE(%NoDwrNetAudioControl=0 And %NoDwrNetAudioControlLocal=0),PRIORITY(8500)
#!#DECLARE(%VolumePcntStrPropText)
#SET(%VolumePcntStrPropText,'((AudioVolume/1000) * 100) & <39> %<39>')
%rasObjectName.SetVolume(AudioVolume/1000)
?VolumePcntStr{PROP:Text} = %VolumePcntStrPropText
#ENDAT
#!------------------------------------------------------------------------------
#GROUP(%ReadGlobal,%pa,%force)
  #INSERT(%SetFamily)
  #FOR(%applicationTemplate),Where(%applicationTemplate='Activate_DwrNetAudioControl(dwrNetAudioControl)')
    #FOR(%applicationTemplateInstance)
      #Context(%application,%applicationTemplateInstance)
        #insert(%ReadClassesPR,'dwrAudioControl.INC',%pa,%force)
      #EndContext
    #EndFor
  #EndFor
#! --------------------------------------------------------------------------
#GROUP(%dwrAddDependency, %pAssemblyName, %pAssemblyVersion, %pLinkManifest),AUTO
  #DECLARE(%ManifestFile)
  #SET(%ManifestFile, %ProjectTarget & '.manifest')
  #IF(NOT FILEEXISTS(%ManifestFile))
    #! create manifest if not exists
    #CALL(%dwrCreateManifest, %ManifestFile, %pAssemblyName, %pAssemblyVersion)
  #ELSE
    #! insert/update dependency
    #CALL(%dwrUpdateManifest, %ManifestFile, %pAssemblyName, %pAssemblyVersion)
  #ENDIF
  #IF(%pLinkManifest)
     #PROJECT(%ManifestFile)
  #ENDIF
#! --------------------------------------------------------------------------
#GROUP(%dwrCreateManifest, %pManifestFile, %pAssemblyName, %pAssemblyVersion),AUTO
  #CREATE(%pManifestFile)
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <assemblyIdentity
    version="1.0.0.0"
    processorArchitecture="X86"
    name="SoftVelocity.Clarion%CWVersion.Application"
    type="win32"
  />
  <description>%Application</description>
  #CALL(%dwrInsertDependency, %pAssemblyName, %pAssemblyVersion)
</assembly>
  #CLOSE(%pManifestFile)
#! --------------------------------------------------------------------------
#GROUP(%dwrUpdateManifest, %pManifestFile, %pAssemblyName, %pAssemblyVersion),AUTO
  #DECLARE(%FileLine)
  #DECLARE(%AssemblyFound, LONG)
  #DECLARE(%TmpFile)
  #SET(%TmpFile, %ManifestFile &'.$$$')
  #OPEN(%pManifestFile),READ
  #CREATE(%TmpFile)
  #LOOP
    #READ(%FileLine)
    #IF(%FileLine = %EOF)
      #BREAK
    #ENDIF
    #IF(INSTRING(' version="',%FileLine,1,1) > 0 AND %AssemblyFound)
        version="%pAssemblyVersion"
    #ELSIF(INSTRING(' name="'& %pAssemblyName &'"',%FileLine,1,1) > 0)
      #SET(%AssemblyFound, %True)
%FileLine
    #ELSIF(INSTRING('</assembly>',%FileLine,1,1) > 0 AND NOT %AssemblyFound)
      #CALL(%dwrInsertDependency, %pAssemblyName, %pAssemblyVersion)
%FileLine
    #ELSE  
%FileLine
    #ENDIF
  #ENDLOOP
  #CLOSE(%pManifestFile),READ
  #CLOSE(%TmpFile)
  #REPLACE(%pManifestFile,%TmpFile)
  #REMOVE(%TmpFile)
#! --------------------------------------------------------------------------
#GROUP(%dwrInsertDependency, %pAssemblyName, %pAssemblyVersion),AUTO
  <dependency>
    <dependentAssembly>
      <assemblyIdentity name="%pAssemblyName" version="%pAssemblyVersion" processorArchitecture="x86"/>
    </dependentAssembly>
  </dependency>
#! --------------------------------------------------------------------------
#GROUP(%dwrCreateDLLManifest)
  #!#DECLARE(%pDllManifestFile)
  #SET(%pDllManifestFile, 'claAudio.manifest')
  #IF(NOT FILEEXISTS(%pDllManifestFile))
    #CREATE(%pDllManifestFile)
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
<assemblyIdentity name="claAudio" version="1.0.0.0" processorArchitecture="x86"></assemblyIdentity>
<clrClass clsid="{E97135B1-F369-36DD-A6F0-E9925699987A}" progid="ClaAudio" threadingModel="Both" name="claAudio.AudioControl" runtimeVersion="v4.0.30319"></clrClass>
<clrClass clsid="{E4FA5365-4B55-38FD-9632-269C8254C5AE}" progid="claAudio.AudioControl+OutputDevicesData" threadingModel="Both" name="claAudio.AudioControl+OutputDevicesData" runtimeVersion="v4.0.30319"></clrClass>
<clrClass clsid="{A9F970ED-01DD-38BA-A9C5-A3680DF14F11}" progid="claAudio.AudioControl+OnSendOutputDevice" threadingModel="Both" name="claAudio.AudioControl+OnSendOutputDevice" runtimeVersion="v4.0.30319"></clrClass>
<file name="claAudio.dll" hashalg="SHA1"></file>
</assembly>
    #CLOSE(%pDllManifestFile)
  #ENDIF
#PROJECT(%pDllManifestFile)

