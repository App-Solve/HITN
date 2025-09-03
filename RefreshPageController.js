({
    invoke: function(component, event, helper) {
        console.log("Invoke method called");
        var flow = component.find("flowData");
        flow.startFlow("Key_Fields");
    }
})