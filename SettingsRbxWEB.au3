#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=rbx.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=SettingsRbxWEB
#AutoIt3Wrapper_Res_Fileversion=0.0.0.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=SettingsRbxWEB
#AutoIt3Wrapper_Res_ProductVersion=0.0.0.0
#AutoIt3Wrapper_Res_CompanyName=SettingsRbxWEB
#AutoIt3Wrapper_Res_LegalCopyright=Copyright © Luis Garcia
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;by LuSlower
#include <GUIConstants.au3>
#include <JSON.au3>
#include <File.au3>
#include <WinAPIProc.au3>
#include <Process.au3>
#include <Misc.au3>

_Singleton("SettingsRbxWEB_x64.exe")

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

Global $INI = @ScriptDir & "\SettingsRbxWEB.ini"
Global $Idxversion = IniRead($INI, "RbxSettings", "dxversion", "4")
Global $Ivulkan = IniRead($INI, "RbxSettings", "vulkan", "4")
Global $Igrass = IniRead($INI, "RbxSettings", "grass", "4")
Global $IQuality = IniRead($INI, "RbxSettings", "quality", "4")
Global $Ishadow = IniRead($INI, "RbxSettings", "shadow", "4")
Global $Ieffects = IniRead($INI, "RbxSettings", "effects", "4")
Global $IlowTexture = IniRead($INI, "RbxSettings", "lowtexture", "4")
Global $Ipol = IniRead($INI, "RbxSettings", "polygons", "4")
Global $Iaa = IniRead($INI, "RbxSettings", "anti-aliasing", "4")
Global $Iht = IniRead($INI, "RbxSettings", "hyper-threading", "4")
Global $Ifps = IniRead($INI, "RbxSettings", "fps", "60")

Local $rbxPID = ProcessExists("RobloxPlayerBeta.exe")
	Switch $rbxPID
		Case 0
			MsgBox(16, "Error", "Debe tener roblox abierto para aplicar los cambios")
			Exit
		Case else
			Local $hProcess = _WinAPI_OpenProcess(BitOR($PROCESS_QUERY_INFORMATION, $PROCESS_VM_READ), False, $rbxPID, True)
			;get
			Local $fpath = _WinAPI_GetModuleFileNameEx($hProcess, Null)
			Local $path = StringRegExpReplace($fpath,  "\\[^\\]+$" , "")
			;get version
			Local $inicio = StringInStr($fpath, "version-")
			Local $spath = StringMid($fpath, $inicio)
			Local $version = StringRegExpReplace($spath, "\\[^\\]+$" , "")

			$json = $path & "\ClientSettings\ClientAppSettings.json"
			If FileExists($json) Then
				MsgBox(64, "Info", "Al parecer se ha detectado una configuración, esta se reemplazará")
			EndIf
EndSwitch

GUICreate("RbxSettingsWeb | LuSlower", 314, 200, 272, 168)

;CheckBox
Global $Cdxversion = GUICtrlCreateRadio("Force Dx11 (Default 10)", 170,8, 137, 17)
GUICtrlSetState(-1, $Idxversion)
Global $Cvulkan = GUICtrlCreateRadio("Force Vulkan (Break)", 170, 32, 137, 17)
GUICtrlSetState(-1, $Ivulkan)
Global $Cgrass = GUICtrlCreateCheckbox("Disable Grass", 16, 8, 97, 17)
GUICtrlSetState(-1, $Igrass)
Global $Cshadow = GUICtrlCreateCheckbox("Disable Shadows", 16, 32, 97, 17)
GUICtrlSetState(-1, $Ishadow)
Global $Ceffects = GUICtrlCreateCheckbox("Disable Effects", 16, 56, 97, 17)
GUICtrlSetState(-1, $Ieffects)
Global $CQuality = GUICtrlCreateCheckbox("Disable DPIScale (low quality)", 16, 80, Default, 17)
GUICtrlSetState(-1, $IQuality)
Global $Caa = GUICtrlCreateCheckbox("Disable Anti-Alias", 16, 104, 105, 17)
GUICtrlSetState(-1, $Iaa)
Global $CLowTexture = GUICtrlCreateCheckbox("Low Quality Textures", 16, 128, Default, 17)
GUICtrlSetState(-1, $IlowTexture)
Global $Cpol = GUICtrlCreateCheckbox("Disable Polygons model", 16, 152, 97, 17)
GUICtrlSetState(-1, $Ipol)
Global $Cht = GUICtrlCreateCheckbox("Force Hyper-Threading", 16, 176, 137, 17)
GUICtrlSetState(-1, $Iht)

;Frames
GUICtrlCreateGroup("CustomFrames", 180, 60, 120, 95)
GUICtrlCreateLabel("CustomFPS", 215, 80, 59, 17)
Global $Cfps = GUICtrlCreateInput("", 228, 98, 30, 21, $ES_NUMBER)
GUICtrlSetData(-1, $Ifps)

;Run
GUICtrlCreateButton("RUN", 205, 125, 75, 20)
GUICtrlSetOnEvent(-1, "_SetSettings")
GUISetOnEvent($GUI_EVENT_CLOSE, "_close")
GUICtrlCreateLabel("Version de Roblox WEB " & @CRLF & $version, 180, 165)
GUISetState(@SW_SHOW)

While True
	Sleep(10000)
WEnd

_SetSettings()

Func _SetSettings()
	Local $fps = GUICtrlRead($Cfps), _
			$dxversion = GUICtrlRead($Cdxversion), _
			$vulkan = GUICtrlRead($Cvulkan), _
			$grass = GUICtrlRead($Cgrass), _
			$shadow = GUICtrlRead($Cshadow), _
			$quality = GUICtrlRead($CQuality), _
			$aa = GUICtrlRead($Caa), _
			$lowtexture = GUICtrlRead($CLowTexture), _
			$effects = GUICtrlRead($Ceffects), _
			$pol = GUICtrlRead($Cpol), _
			$ht = GUICtrlRead($Cht)

	Local $check_fps = StringIsInt($fps)
	Select
		Case $check_fps = 0 Or $fps = 0 Or $fps > 250
			MsgBox(16, "Error", "Por favor escriba un numero valido de fps")
			Return
	EndSelect
	Global $_map
	_FileCreate($json)
	_JSON_addChangeDelete($_map, "DFIntTaskSchedulerTargetFps", $fps)
		If $dxversion = 4 Then
		;Force Dx10
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsDisableDirect3D11", "false")
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11", "false")
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11FL10", "false")
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11FL10", "false")
	Else
		;Force Dx11
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsDisableDirect3D11", "true")
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11", "true")
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11FL10", "false")
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11FL10", "false")
	EndIf
	If $vulkan = 4 Then
		;Disable Dx
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsDisableDirect3D11", Default)
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11", Default)
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11FL10", Default)
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferD3D11FL10", Default)
		;Force Vulkan
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsDisableVulkan", Default)
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsDisableVulkan11", Default)
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferVulkan", Default)
		_JSON_addChangeDelete($_map, "FFlagRenderVulkanFixMinimizeWindow", Default)
	Else
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsDisableVulkan", Default)
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsDisableVulkan11", Default)
		_JSON_addChangeDelete($_map, "FFlagDebugGraphicsPreferVulkan", Default)
		_JSON_addChangeDelete($_map, "FFlagRenderVulkanFixMinimizeWindow", Default)
	EndIf
	If $grass = 1 Then
		;Disable grass
		_JSON_addChangeDelete($_map, "FIntFRMMinGrassDistance", "0")
		_JSON_addChangeDelete($_map, "FIntFRMMaxGrassDistance", "0")
		_JSON_addChangeDelete($_map, "FIntRenderGrassDetailStrands", "0")
		_JSON_addChangeDelete($_map, "FIntRenderGrassHeightScaler", "0")
	Else
		_JSON_addChangeDelete($_map, "FIntFRMMinGrassDistance", Default)
		_JSON_addChangeDelete($_map, "FIntFRMMaxGrassDistance", Default)
		_JSON_addChangeDelete($_map, "FIntRenderGrassDetailStrands", Default)
		_JSON_addChangeDelete($_map, "FIntRenderGrassHeightScaler", Default)
	EndIf
	If $shadow = 1 Then
		;Disable shadows
		_JSON_addChangeDelete($_map, "FIntRenderShadowIntensity", "0")
	Else
		_JSON_addChangeDelete($_map, "FIntRenderShadowIntensity", Default)
	EndIf
	If $lowtexture = 1 Then
		;Low Textures
		_JSON_addChangeDelete($_map, "DFFlagTextureQualityOverrideEnabled", "true")
		_JSON_addChangeDelete($_map, "DFIntTextureQualityOverride", "0")
	Else
		_JSON_addChangeDelete($_map, "DFFlagTextureQualityOverrideEnabled", Default)
		_JSON_addChangeDelete($_map, "DFIntTextureQualityOverride", Default)
	EndIf
	If $quality = 1 Then
		;Disable shadows
		_JSON_addChangeDelete($_map, "DFFlagDisableDPIScale", "false")
	Else
		_JSON_addChangeDelete($_map, "DFFlagDisableDPIScale", Default)
	EndIf
	If $effects = 1 Then
		;Disable Effects
		_JSON_addChangeDelete($_map, "FFlagDisablePostFx", "true")
	Else
		_JSON_addChangeDelete($_map, "FFlagDisablePostFx", Default)
	EndIf
	;Disable AA
	If $aa = 1 Then
		_JSON_addChangeDelete($_map, "FIntDebugForceMSAASamples", "0")
	Else
		_JSON_addChangeDelete($_map, "FIntDebugForceMSAASamples", Default)
	EndIf
	;Disable Polygons model
	If $pol = 1 Then
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistance", "0")
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistanceL12", "0")
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistanceL23", "0")
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistanceL34", "0")
	Else
		;Disable Polygons model
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistance", Default)
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistanceL12", Default)
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistanceL23", Default)
		_JSON_addChangeDelete($_map, "DFIntCSGLevelOfDetailSwitchingDistanceL34", Default)
	EndIf
	If $ht = 1 Then
		;Disable Hyper-Threding
		_JSON_addChangeDelete($_map, "FFlagRenderCheckThreading", "True")
	Else
		_JSON_addChangeDelete($_map, "FFlagRenderCheckThreading", Default)
	EndIf
	;Prioritys Rbx
	Local $RbxKey = "HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RobloxPlayerBeta.exe\PerfOptions"
	RegWrite($RbxKey, "CpuPriorityClass", "REG_DWORD", "0x3")
	RegWrite($RbxKey, "IoPriority", "REG_DWORD", "0x3")

	Global $data = _JSON_Generate($_map) ;generar mapa JSON
	FileWrite($json, $data) ;escribir datos

	;Write INI data
	IniWrite($INI, "RbxSettings", "dxversion", $dxversion)
	IniWrite($INI, "RbxSettings", "vulkan", $vulkan)
	IniWrite($INI, "RbxSettings", "grass", $grass)
	IniWrite($INI, "RbxSettings", "shadow", $shadow)
	IniWrite($INI, "RbxSettings", "quality", $quality)
	IniWrite($INI, "RbxSettings", "effects", $effects)
	IniWrite($INI, "RbxSettings", "polygons", $pol)
	IniWrite($INI, "RbxSettings", "lowtexture", $lowtexture)
	IniWrite($INI, "RbxSettings", "anti-aliasing", $aa)
	IniWrite($INI, "RbxSettings", "hyper-threading", $ht)
	IniWrite($INI, "RbxSettings", "fps", $fps)
	_RunDos("Taskkill -t -f -im RobloxPlayerBeta.exe")
	ConsoleWrite($data)
	MsgBox(64, "Info", "FPS " & "(" & $fps & ")" & " y ajustes aplicados correctamente")
EndFunc   ;==>_SetSettings
Exit

Func _close()
	GUIDelete()
	Exit
EndFunc   ;==>_close
