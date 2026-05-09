# mesh-preview.yazi

A [Yazi](https://yazi-rs.github.io/) plugin to preview 3D mesh files and point clouds in the terminal.

![Preview](https://github.com/dimi1357/mesh-preview.yazi/raw/main/preview.png)

## Features

- Preview 3D meshes with shaded rendering
- Support for point clouds with height-based coloring
- Automatic mesh simplification for large files
- Fast rendering using matplotlib

## Supported Formats

| Format | Extension | Type |
|--------|-----------|------|
| Wavefront OBJ | `.obj` | Mesh |
| STL | `.stl` | Mesh |
| PLY | `.ply` | Mesh / Point Cloud |
| glTF | `.gltf`, `.glb` | Mesh |
| FBX | `.fbx` | Mesh |
| 3D Studio | `.3ds` | Mesh |
| OFF | `.off` | Mesh |
| COLLADA | `.dae` | Mesh |
| VRML | `.wrl` | Mesh |
| VTK | `.vtk` | Mesh |

## Requirements

- Python 3.8+
- The plugin creates its own virtual environment with dependencies

## Installation

### Using `ya pack`

```bash
ya pack -a dimi1357/mesh-preview
```

### Using `ya pkg`

```bash
ya pkg add dimi1357/mesh-preview
```

### Manual Installation

1. Clone to your yazi plugins directory:

```bash
git clone https://github.com/dimi1357/mesh-preview.yazi.git ~/.config/yazi/plugins/mesh-preview.yazi
```

2. Create virtual environment and install dependencies:

```bash
cd ~/.config/yazi/plugins/mesh-preview.yazi
python3 -m venv .venv
.venv/bin/pip install trimesh pillow numpy matplotlib fast-simplification
```

3. Add to your `~/.config/yazi/yazi.toml`:

```toml
[plugin]
prepend_previewers = [
    { url = "*.obj", run = "mesh-preview" },
    { url = "*.stl", run = "mesh-preview" },
    { url = "*.ply", run = "mesh-preview" },
    { url = "*.gltf", run = "mesh-preview" },
    { url = "*.glb", run = "mesh-preview" },
    { url = "*.fbx", run = "mesh-preview" },
    { url = "*.3ds", run = "mesh-preview" },
    { url = "*.off", run = "mesh-preview" },
    { url = "*.dae", run = "mesh-preview" },
]
```

## How It Works

1. When you hover over a 3D file, the Lua plugin calls the Python renderer
2. The Python script uses trimesh to load the geometry
3. Large meshes are automatically simplified using fast-simplification
4. The result is rendered with matplotlib and cached for instant subsequent views

## Configuration

Edit `render_mesh.py` to customize:
- `MAX_FACES` - Maximum faces before simplification (default: 50000)
- `MAX_POINTS` - Maximum points for point clouds (default: 100000)
- Background color, colormap, lighting, viewing angle

## License

MIT License - see [LICENSE](LICENSE) for details.
