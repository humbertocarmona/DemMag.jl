# trace generated using paraview version 5.7.0
#
# To ensure correct image size when batch processing, please search
# for and uncomment the line `# renderView*.ViewSize = [*,*]`

#### import the simple module from the paraview
from paraview.simple import *
from subprocess import check_output
import re

arrowvar = 'mag'
arrowscal = 0.3
particelevar = 'active'
L = [220.0, 220.0, 20.0]
L = [50,50, 10.0]
R = 0.5 #0.442

#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()
findCommand ='find {:}  -regex "{:}" |sort'.format("./",".*snap_.*\.vtu")

files = check_output(findCommand, shell=True)
files = files.decode("utf-8")
files = files.strip()  # required to remove last blank line
files = re.split('\n', files)

print(files[1],"..",files[-1])

# create a new 'XML Unstructured Grid Reader'
snap_0 = XMLUnstructuredGridReader(FileName=files)
snap_0.PointArrayStatus = ['vel', 'mag', 'angvel', 'idx', 'active', 'fcontact', 'fmag', 'ftot']

# get animation scene
animationScene1 = GetAnimationScene()

# get the time-keeper
timeKeeper1 = GetTimeKeeper()

# update animation scene based on data timesteps
animationScene1.UpdateAnimationUsingDataTimeSteps()

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')
# uncomment following to set a specific view size
# renderView1.ViewSize = [1492, 793]

# show data in view
snap_0Display = Show(snap_0, renderView1)
snap_0Display.Representation = 'Point Gaussian'
snap_0Display.GaussianRadius = R
snap_0Display.ColorArrayName = ['Points', particelevar]
snap_0Display.OSPRayScaleArray = particelevar
snap_0Display.OSPRayScaleFunction = 'PiecewiseFunction'
snap_0Display.ScaleTransferFunction = 'PiecewiseFunction'
snap_0Display.OpacityTransferFunction = 'PiecewiseFunction'
snap_0Display.DataAxesGrid = 'GridAxesRepresentation'
snap_0Display.PolarAxes = 'PolarAxesRepresentation'
snap_0Display.ScalarOpacityUnitDistance = 2.5

# snap_0Display.ScaleTransferFunction.Points = [1.0, 0.0, 0.5, 0.0, 2.0, 1.0, 0.5, 0.0]
# snap_0Display.OpacityTransferFunction.Points = [1.0, 0.0, 0.5, 0.0, 2.0, 1.0, 0.5, 0.0]
ColorBy(snap_0Display, particelevar)

# threshold1 = Threshold(Input=snap_0)
# threshold1.Scalars = ['POINTS', 'active']
# threshold1.ThresholdRange = [0.9, 1.1]
# threshold1Display = Show(threshold1, renderView1)
# threshold1Display.Representation = 'Point Gaussian'
# threshold1Display.GaussianRadius = 0.5
# threshold1Display.AmbientColor = [0.6, 0.6, 0.6]
# threshold1Display.DiffuseColor = [0.6, 0.6, 0.6]

# init the 'Arrow' selected for 'GlyphType'
# snap_0Display.GlyphType.TipResolution = 25
# snap_0Display.GlyphType.TipLength = 0.4
# snap_0Display.GlyphType.ShaftResolution = 25
# snap_0Display.GlyphType.ShaftRadius = 0.05

# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'

# reset view to fit data

#changing interaction mode based on data extents
# renderView1.InteractionMode = '2D'
# renderView1.CameraPosition = [10050.0, 48.75, 0.5]
# renderView1.CameraFocalPoint = [50.0, 48.75, 0.5]
# renderView1.CameraViewUp = [0.0, 1.0, 0.0]

# get the material library
materialLibrary1 = GetMaterialLibrary()

# renderView1.Update()

# create a new 'Glyph'
glyph1 = Glyph(Input=snap_0,GlyphType='Arrow')
glyph1.OrientationArray = ['POINTS', arrowvar]
glyph1.ScaleArray = ['POINTS', arrowvar]
glyph1.ScaleFactor = arrowscal
glyph1.GlyphTransform = 'Transform2'
glyph1.GlyphType.TipResolution = 25
glyph1.GlyphType.TipLength = 0.5
glyph1.GlyphType.TipRadius = 0.4
glyph1.GlyphType.ShaftResolution = 25
glyph1.GlyphType.ShaftRadius = 0.2
glyph1.GlyphMode = 'All Points'

# create a new 'Glyph'
glyph2 = Glyph(Input=snap_0,GlyphType='Arrow')
glyph2.OrientationArray = ['POINTS', arrowvar]
glyph2.ScaleArray = ['POINTS', arrowvar]
glyph2.ScaleFactor = -arrowscal
glyph2.GlyphTransform = 'Transform2'
glyph2.GlyphType.TipResolution = 25
glyph2.GlyphType.TipLength = 0.
glyph2.GlyphType.ShaftResolution = 25
glyph2.GlyphType.ShaftRadius = 0.2
glyph2.GlyphMode = 'All Points'

# show data in view
glyph1Display = Show(glyph1, renderView1)
glyph2Display = Show(glyph2, renderView1)
# ColorBy(glyph1Display, None)
# ColorBy(glyph2Display, None)

line1 = Line()

line1.Point1 = [-L[0]/2, 0, 0.0]
line1.Point2 = [L[0]/2, 0, 0.0]
line1Display = Show(line1, renderView1)
line1Display.Opacity = 0.2

line2 = Line()
line2.Point1 = [0, -L[1]/2, 0.0]
line2.Point2 = [0, L[1]/2, 0.0]
line2Display = Show(line2, renderView1)
line2Display.Opacity = 0.2

# plane1 = Plane()
# plane1.Origin = [-L[0]/2, -L[1]/2, 0.0]
# plane1.Point1 = [L[0]/2, -L[1]/2, 0.0]
# plane1.Point2 = [ -L[0]/2, L[1]/2, 0.0]
# plane1.XResolution = 10
# plane1.YResolution = 10
# plane1Display = Show(plane1, renderView1)
# plane1Display.Representation = 'Outline'
# plane1Display.SetRepresentationType('Outline')

box1 = Box()
box1.XLength = L[0]
box1.YLength = L[1]
box1.ZLength = L[2]
box1Display = Show(box1, renderView1)
box1Display.Representation = 'Wireframe'

SetActiveSource(snap_0)
# get color transfer function/color map for 'fcontact'
fcontactLUT = GetColorTransferFunction('fcontact')
fcontactPWF = GetOpacityTransferFunction('fcontact')
fcontactLUT.RescaleTransferFunction(0.0, 4.5)
fcontactPWF.RescaleTransferFunction(0.0, 4.5)

# get color transfer function/color map for 'neigh'
neighLUT = GetColorTransferFunction('neigh')
neighPWF = GetOpacityTransferFunction('neigh')
neighLUT.RescaleTransferFunction(0.0, 5.0)
neighPWF.RescaleTransferFunction(0.0, 5.0)

# get color transfer function/color map for 'neigh'
velLUT = GetColorTransferFunction('vel')
velPWF = GetOpacityTransferFunction('vel')
velLUT.RescaleTransferFunction(0.0, 1.0)
velPWF.RescaleTransferFunction(0.0, 1.0)

renderView1.Update()

# current camera placement for renderView1
renderView1.ResetCamera()
renderView1.InteractionMode = '2D'
renderView1.CameraPosition = [0, 0, 20]
renderView1.CameraFocalPoint = [0, 0, 0]
renderView1.CameraParallelScale = 60.0
