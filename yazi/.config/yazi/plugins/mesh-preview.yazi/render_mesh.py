#!/usr/bin/env python3
"""
Render 3D mesh/point cloud files to PNG images for yazi preview.
Usage: render_mesh.py <input_file> <output_file> [width] [height]
"""

import sys
import os

# Maximum faces/points for rendering
MAX_FACES = 50000
MAX_POINTS = 100000


def simplify_mesh(vertices, faces, target_faces):
    """Simplify mesh to target number of faces using fast-simplification."""
    import numpy as np
    
    if len(faces) <= target_faces:
        return vertices, faces
    
    try:
        import fast_simplification
        ratio = target_faces / len(faces)
        simplified_vertices, simplified_faces = fast_simplification.simplify(
            vertices.astype(np.float32),
            faces.astype(np.int32),
            target_reduction=1.0 - ratio
        )
        return simplified_vertices, simplified_faces
    except Exception as e:
        print(f"Simplification failed: {e}", file=sys.stderr)
        return vertices, faces[:target_faces]


def render_point_cloud(points, colors, output_path, width, height):
    """Render a point cloud to a PNG image."""
    import numpy as np
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    # Subsample if too many points
    if len(points) > MAX_POINTS:
        indices = np.random.choice(len(points), MAX_POINTS, replace=False)
        points = points[indices]
        if colors is not None:
            colors = colors[indices]

    # Center and normalize
    centroid = points.mean(axis=0)
    points = points - centroid
    max_extent = np.abs(points).max()
    if max_extent > 0:
        points = points / max_extent * 0.85

    # Create figure
    fig = plt.figure(figsize=(width/100, height/100), dpi=100)
    fig.patch.set_facecolor('#1e1e2e')
    
    ax = fig.add_subplot(111, projection='3d')
    ax.set_facecolor('#1e1e2e')

    # Determine point colors
    if colors is not None and len(colors) == len(points):
        # Use provided colors (normalize to 0-1 if needed)
        if colors.max() > 1:
            colors = colors / 255.0
        point_colors = colors
    else:
        # Color by height (z-coordinate)
        z_normalized = (points[:, 2] - points[:, 2].min()) / (points[:, 2].max() - points[:, 2].min() + 1e-8)
        point_colors = plt.cm.plasma(z_normalized * 0.6 + 0.2)

    # Plot points
    ax.scatter(
        points[:, 0], points[:, 1], points[:, 2],
        c=point_colors,
        s=1,  # Point size
        alpha=0.8,
        depthshade=True
    )

    # Set axis limits
    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)
    ax.set_zlim(-1, 1)
    
    ax.view_init(elev=20, azim=45)
    ax.set_axis_off()
    ax.set_box_aspect([1, 1, 1])
    
    plt.tight_layout(pad=0)
    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
    
    plt.savefig(
        output_path,
        format='png',
        facecolor=fig.get_facecolor(),
        edgecolor='none',
        bbox_inches='tight',
        pad_inches=0.05,
        dpi=100
    )
    plt.close(fig)


def render_mesh(vertices, faces, output_path, width, height):
    """Render a mesh to a PNG image."""
    import numpy as np
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection

    # Simplify if needed
    if len(faces) > MAX_FACES:
        print(f"Simplifying mesh: {len(faces)} -> {MAX_FACES} faces", file=sys.stderr)
        vertices, faces = simplify_mesh(vertices, faces, MAX_FACES)
        print(f"Simplified to {len(faces)} faces", file=sys.stderr)

    # Center and normalize
    centroid = vertices.mean(axis=0)
    vertices = vertices - centroid
    max_extent = np.abs(vertices).max()
    if max_extent > 0:
        vertices = vertices / max_extent * 0.85

    # Create figure
    fig = plt.figure(figsize=(width/100, height/100), dpi=100)
    fig.patch.set_facecolor('#1e1e2e')
    
    ax = fig.add_subplot(111, projection='3d')
    ax.set_facecolor('#1e1e2e')
    
    # Create polygon collection
    poly3d = [[vertices[idx] for idx in face] for face in faces]
    
    # Compute face normals for shading
    v0 = vertices[faces[:, 0]]
    v1 = vertices[faces[:, 1]]
    v2 = vertices[faces[:, 2]]
    face_normals = np.cross(v1 - v0, v2 - v0)
    norms = np.linalg.norm(face_normals, axis=1, keepdims=True)
    norms[norms == 0] = 1
    face_normals = face_normals / norms
    
    # Multi-directional lighting
    lights = [
        (np.array([1.0, 0.5, 0.8]), 0.5),
        (np.array([-0.5, 1.0, 0.5]), 0.3),
        (np.array([0.0, -0.5, 1.0]), 0.2),
    ]
    
    intensities = np.zeros(len(faces))
    for light, strength in lights:
        light = light / np.linalg.norm(light)
        intensities += np.abs(np.dot(face_normals, light)) * strength
    
    intensities = np.clip(intensities + 0.2, 0.2, 1.0)
    colors = plt.cm.plasma(intensities * 0.6 + 0.2)
    
    collection = Poly3DCollection(
        poly3d,
        facecolors=colors,
        edgecolors='none',
        alpha=1.0
    )
    ax.add_collection3d(collection)

    # Set axis limits
    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)
    ax.set_zlim(-1, 1)
    
    # Auto viewing angle
    extents = vertices.max(axis=0) - vertices.min(axis=0)
    if extents[2] < extents[0] * 0.3 and extents[2] < extents[1] * 0.3:
        ax.view_init(elev=60, azim=45)
    else:
        ax.view_init(elev=20, azim=45)
    
    ax.set_axis_off()
    ax.set_box_aspect([1, 1, 1])
    
    plt.tight_layout(pad=0)
    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
    
    plt.savefig(
        output_path,
        format='png',
        facecolor=fig.get_facecolor(),
        edgecolor='none',
        bbox_inches='tight',
        pad_inches=0.05,
        dpi=100
    )
    plt.close(fig)


def load_and_render(input_path: str, output_path: str, width: int = 800, height: int = 600):
    """Load a 3D file and render it appropriately."""
    import trimesh
    import numpy as np

    # Load the file
    data = trimesh.load(input_path)
    
    # Handle different types
    if isinstance(data, trimesh.PointCloud):
        # Point cloud
        points = np.array(data.vertices)
        colors = np.array(data.colors) if hasattr(data, 'colors') and data.colors is not None else None
        if colors is not None and len(colors) > 0:
            colors = colors[:, :3]  # Remove alpha if present
        render_point_cloud(points, colors, output_path, width, height)
        
    elif isinstance(data, trimesh.Scene):
        # Scene with multiple geometries
        meshes = []
        points_list = []
        
        for geom in data.geometry.values():
            if isinstance(geom, trimesh.Trimesh):
                meshes.append(geom)
            elif isinstance(geom, trimesh.PointCloud):
                points_list.append(np.array(geom.vertices))
        
        if meshes:
            mesh = trimesh.util.concatenate(meshes)
            render_mesh(mesh.vertices.copy(), mesh.faces.copy(), output_path, width, height)
        elif points_list:
            points = np.vstack(points_list)
            render_point_cloud(points, None, output_path, width, height)
        else:
            raise ValueError("No renderable geometry found in scene")
            
    elif isinstance(data, trimesh.Trimesh):
        # Single mesh
        render_mesh(data.vertices.copy(), data.faces.copy(), output_path, width, height)
        
    else:
        raise ValueError(f"Unsupported geometry type: {type(data)}")
    
    return True


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <input_file> <output_file> [width] [height]", file=sys.stderr)
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    width = int(sys.argv[3]) if len(sys.argv) > 3 else 800
    height = int(sys.argv[4]) if len(sys.argv) > 4 else 600
    
    if not os.path.exists(input_path):
        print(f"Error: Input file not found: {input_path}", file=sys.stderr)
        sys.exit(1)
    
    try:
        load_and_render(input_path, output_path, width, height)
        print(f"Rendered: {output_path}")
        sys.exit(0)
    except Exception as e:
        print(f"Error rendering mesh: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
