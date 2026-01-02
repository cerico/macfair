---
name: threejs
description: Build 3D scenes, animations, and interactive experiences with Three.js. Use for product viewers, backgrounds, data visualization, or creative experiments.
---

# Three.js

Build 3D scenes and interactive experiences for the web.

## Status: Starter

Patterns will evolve with use.

## When to Use

- Product viewers / 3D showcases
- Interactive backgrounds
- Data visualization in 3D
- Creative experiments
- Game-like experiences

## Setup

### Vanilla

```bash
pnpm add three
pnpm add -D @types/three
```

### React (React Three Fiber)

```bash
pnpm add three @react-three/fiber @react-three/drei
pnpm add -D @types/three
```

## Basic Patterns

### Vanilla Three.js

```typescript
import * as THREE from 'three'

const scene = new THREE.Scene()
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
const renderer = new THREE.WebGLRenderer({ antialias: true })

renderer.setSize(window.innerWidth, window.innerHeight)
document.body.appendChild(renderer.domElement)

// Add a cube
const geometry = new THREE.BoxGeometry()
const material = new THREE.MeshStandardMaterial({ color: 0x00ff00 })
const cube = new THREE.Mesh(geometry, material)
scene.add(cube)

// Add light
const light = new THREE.DirectionalLight(0xffffff, 1)
light.position.set(5, 5, 5)
scene.add(light)

camera.position.z = 5

// Animation loop
function animate() {
  requestAnimationFrame(animate)
  cube.rotation.x += 0.01
  cube.rotation.y += 0.01
  renderer.render(scene, camera)
}
animate()
```

### React Three Fiber

```tsx
import { Canvas } from '@react-three/fiber'
import { OrbitControls, Environment } from '@react-three/drei'

function Box() {
  return (
    <mesh>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="orange" />
    </mesh>
  )
}

export default function Scene() {
  return (
    <Canvas camera={{ position: [3, 3, 3] }}>
      <ambientLight intensity={0.5} />
      <directionalLight position={[10, 10, 5]} />
      <Box />
      <OrbitControls />
      <Environment preset="studio" />
    </Canvas>
  )
}
```

## Common Recipes

### Load GLTF Model

```tsx
import { useGLTF } from '@react-three/drei'

function Model() {
  const { scene } = useGLTF('/model.glb')
  return <primitive object={scene} />
}
```

### Responsive Canvas

```tsx
<Canvas
  style={{ width: '100%', height: '100vh' }}
  camera={{ position: [0, 0, 5], fov: 50 }}
  dpr={[1, 2]}
>
```

### Post-Processing

```bash
pnpm add @react-three/postprocessing
```

```tsx
import { EffectComposer, Bloom } from '@react-three/postprocessing'

<EffectComposer>
  <Bloom luminanceThreshold={0.9} intensity={0.5} />
</EffectComposer>
```

### Animation with useFrame

```tsx
import { useFrame } from '@react-three/fiber'
import { useRef } from 'react'

function SpinningBox() {
  const ref = useRef()
  useFrame((state, delta) => {
    ref.current.rotation.y += delta
  })
  return (
    <mesh ref={ref}>
      <boxGeometry />
      <meshStandardMaterial color="hotpink" />
    </mesh>
  )
}
```

## AI Asset Pipeline (Nano Banana)

1. Generate image in Google AI Studio with Nano Banana
2. Convert to 3D via Tripo, Meshy, or similar
3. Export as GLTF/GLB
4. Load in Three.js

## Reference

- Three.js docs: https://threejs.org/docs/
- React Three Fiber: https://docs.pmnd.rs/react-three-fiber
- Drei helpers: https://github.com/pmndrs/drei
- Three.js examples: https://threejs.org/examples/

## TODO

- [ ] First real project to establish patterns
- [ ] Decide vanilla vs React Three Fiber preference
- [ ] Add shader patterns
- [ ] Add physics (rapier) patterns
