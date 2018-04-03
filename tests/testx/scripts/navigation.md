## Check main navigation
---

#### Check that it is possible to navigate to the App Store page
    - set:
        menu.AppStore: 
    - check matches:
        page.title: App Store

#### Check that it is possible to navigate to the Storage page
    - set:
        menu.Storage: 
    - check matches:
        page.title: Storage Buckets

## Check secondary navigation
---

#### Check that the New Instance link on the Instances page navigates to the Apps page
    - set:
        menu.Instances: 
    - check matches:
        page.title: Instances
    - set:
        toolbox.NewInstance: 
    - check matches:
        page.title: Apps

#### Check that the New App link on the Apps page opens an app def edit form
    - set:
        toolbox.NewApp: 
    - wait to appear:
        expectedElement: editAppDefForm.Content
    - set:
        editAppDefForm.Close: 
    - wait to disappear:
        expectedElement: editAppDefForm.Content
