# Installation

Step-by-step guide to setting up and configuring the Lilia framework for your Garry's Mod server.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lilia is a modern roleplay framework designed for performance, modularity, and ease of use. Installing the framework involves setting up the core workshop content, choosing a schema, and configuring initial administrative access.</p>
  <p>This guide covers the standard setup process to get your server joinable and ready for customization.</p>
</div>

---

<h3 style="margin-bottom: 5px; font-weight: 700;">1. Install Lilia Core (Workshop)</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lilia's asset package must be subscribed to on the Steam Workshop for clients to download required materials and textures.</p>
  <ul>
    <li><strong>Workshop ID:</strong> <code>3527535922</code></li>
    <li><a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3527535922">Subscribe to Lilia on Workshop</a></li>
  </ul>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">2. Install a Schema</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lilia requires a schema (a gamemode built on the framework) to operate. We recommend the <strong>Skeleton Schema</strong> for new projects.</p>
  <ol>
    <li><a href="https://github.com/LiliaFramework/Skeleton/releases/download/release/skeleton.zip">Download Skeleton Schema</a></li>
    <li>Extract the ZIP and place the <code>skeleton</code> folder into <code>garrysmod/gamemodes/</code>.</li>
    <li>Update your server startup command: <code>+gamemode skeleton</code></li>
  </ol>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">3. Administrative Setup</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configure yourself as the owner to access in-game menus and configuration tools.</p>
  <p>Run the following in your <strong>server console</strong>:</p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-bottom: 15px; font-family: 'JetBrains Mono', monospace;">plysetgroup "YOUR_STEAMID" "superadmin"</code>
  <p>Lilia is also fully compatible with external admin mods like <strong>SAM</strong>, <strong>ULX</strong>, and <strong>ServerGuard</strong>.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">4. Next Steps</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Once the basic setup is complete, you can begin populating your world:</p>
  <ul>
    <li><a href="../../generators/faction/">Create Factions</a> to define player teams.</li>
    <li><a href="../../generators/class/">Create Classes</a> for sub-roles within factions.</li>
    <li><a href="../../generators/">Generate Items</a> using our automated tools.</li>
    <li><a href="../../modules/">Explore Modules</a> to add specific features.</li>
  </ul>
</div>
