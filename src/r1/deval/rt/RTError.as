package r1.deval.rt
{
   import r1.deval.parser.ParseError;
   
   public class RTError extends Error
   {
       
      
      private var _param1:String;
      
      private var _param2:String;
      
      private var linenos:Array;

      private var lines:Array;
      
      public function RTError(param1:String, param2:String = null, param3:String = null)
      {
         super(ParseError.processMessage(param1));
         _param1 = param2;
         _param2 = param3;
		 this.lines=new Array();
		 this.linenos=new Array();
      }
      
      public function pushline(line:String,lineno:int):void {
         this.lines.push(line);
         this.linenos.push(lineno);
      }
      public function toString() : String
      {
         var _loc1_:String = "Runtime Error: " + super.message;
         for (var j:int=0;j<lines.length;j++) {
            if (j==0) _loc1_+="\n";
            _loc1_+="\tat line: "+linenos[j]+": "+lines[j];
         }
         return _loc1_;
      }
   }
}
