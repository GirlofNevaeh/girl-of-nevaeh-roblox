#!/usr/bin/env python3
"""Pack the Girl of NevaeH Rojo sources into a Studio-openable .rbxlx."""
from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent

def cdata(text: str) -> str:
    if "]]>" in text:
        text = text.replace("]]>", "]]]]><![CDATA[>")
    return f"<![CDATA[{text}]]>"

def script_item(class_name: str, name: str, referent: str, source: str) -> str:
    return f"""  <Item class="{class_name}" referent="{referent}">
    <Properties>
      <string name="Name">{escape(name)}</string>
      <bool name="Disabled">false</bool>
      <ProtectedString name="Source">{cdata(source)}</ProtectedString>
    </Properties>
  </Item>
"""

def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")

xml = f"""<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
  <External>null</External>
  <External>nil</External>
  <Item class="Workspace" referent="RBX1">
    <Properties>
      <string name="Name">Workspace</string>
    </Properties>
    <Item class="SpawnLocation" referent="RBXSPAWN">
      <Properties>
        <string name="Name">SpawnLocation</string>
        <Vector3 name="Size">12 1 12</Vector3>
        <CoordinateFrame name="CFrame">0 4 8 1 0 0 0 1 0 0 0 1</CoordinateFrame>
        <bool name="Anchored">true</bool>
        <float name="Duration">0</float>
        <bool name="Neutral">true</bool>
      </Properties>
    </Item>
  </Item>
  <Item class="Lighting" referent="RBXLIT">
    <Properties>
      <string name="Name">Lighting</string>
      <Color3 name="Ambient">0.08 0.06 0.14</Color3>
      <float name="Brightness">1.4</float>
      <float name="ClockTime">20</float>
      <Color3 name="FogColor">0.08 0.05 0.16</Color3>
      <float name="FogEnd">420</float>
      <float name="FogStart">80</float>
      <Color3 name="OutdoorAmbient">0.12 0.08 0.22</Color3>
    </Properties>
  </Item>
  <Item class="ReplicatedStorage" referent="RBXRS">
    <Properties>
      <string name="Name">ReplicatedStorage</string>
    </Properties>
    <Item class="Folder" referent="RBXNV">
      <Properties>
        <string name="Name">Nevaeh</string>
      </Properties>
{script_item("ModuleScript", "Config", "RBXCFG", read("src/shared/Config.luau"))}
{script_item("ModuleScript", "Questions", "RBXQ", read("src/shared/Questions.luau"))}
    </Item>
  </Item>
  <Item class="ServerScriptService" referent="RBXSSS">
    <Properties>
      <string name="Name">ServerScriptService</string>
    </Properties>
{script_item("Script", "NevaehServer", "RBXSRV", read("src/server/init.server.luau"))}
  </Item>
  <Item class="StarterPlayer" referent="RBXSP">
    <Properties>
      <string name="Name">StarterPlayer</string>
    </Properties>
    <Item class="StarterPlayerScripts" referent="RBXSPS">
      <Properties>
        <string name="Name">StarterPlayerScripts</string>
      </Properties>
{script_item("LocalScript", "NevaehClient", "RBXCLI", read("src/client/init.client.luau"))}
    </Item>
  </Item>
  <Item class="Players" referent="RBXPL">
    <Properties>
      <string name="Name">Players</string>
      <int name="RespawnTime">3</int>
    </Properties>
  </Item>
  <Item class="SoundService" referent="RBXSND">
    <Properties>
      <string name="Name">SoundService</string>
    </Properties>
  </Item>
</roblox>
"""

out = ROOT / "GirlOfNevaeh.rbxlx"
out.write_text(xml, encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")
