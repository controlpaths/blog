function pass = annotate_port(blockName, isInport, portId, annoteString)

pass = true ;
try
ph=get_param(blockName, 'PortHandles');
if ( isInport )
portHandle = get_param(ph.Inport(portId),'Object');
else
portHandle = get_param(ph.Outport(portId),'Object');
end
Simulink.AnnotationGateway.Annotate( portHandle, annoteString);
catch
pass = false;
end
end
