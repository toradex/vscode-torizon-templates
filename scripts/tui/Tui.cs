
//------------------------------------------------------------------------------

//  <auto-generated>
//      This code was generated by:
//        TerminalGuiDesigner v1.0.24.0
//      You can make changes to this file and they will not be overwritten when saving.
//  </auto-generated>
// -----------------------------------------------------------------------------
namespace tui {
    using Terminal.Gui;
    
    
    public partial class Tui {
        
        public int TemplateSelected;
        public string ProjectName;
        public string ContainerName; 

        public Tui() {
            InitializeComponent();

            this.listView.OpenSelectedItem += (item) => {
                this.TemplateSelected = item.Item;
            };
        }
    }
}
