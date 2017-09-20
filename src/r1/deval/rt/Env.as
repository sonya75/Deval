package r1.deval.rt
{
   import flash.utils.describeType;
   import r1.deval.D;
   
   public class Env
   {
      
      public static var outputFunction:Function = trace;
      
      private static var _overrideGlobalOption:int = D.OVERRIDE_GLOBAL_OVERRIDE;
      
      private static var stack:Array = [];
      
      private static const _global:Object = {
         "decodeURI":decodeURI,
         "decodeURIComponent":decodeURIComponent,
         "encodeURI":encodeURI,
         "encodeURIComponent":encodeURIComponent,
         "escape":escape,
         "isFinite":isFinite,
         "isNaN":isNaN,
         "isXMLName":isXMLName,
         "parseFloat":parseFloat,
         "parseInt":parseInt,
         "trace":trace,
         "unescape":unescape,
         "printf":printf,
         "importFunction":importFunction,
         "importStaticMethods":importStaticMethods,
         "Array":Array,
         "Boolean":Boolean,
         "int":int,
         "Number":Number,
         "Object":Object,
         "String":String,
         "uint":uint,
         "XML":XML,
         "XMLList":XMLList,
         "Date":Date,
         "Math":Math,
         "RegExp":RegExp,
         "QName":QName,
         "Namespace":Namespace,
         "Error":Error,
         "Class":Class
      };
      
      public static var INFINITE_LOOP_LIMIT:Number = 100000;
      
      private static const __errors:Object = {
         "msg.no.paren.parms":"missing ( before function parameters.",
         "msg.misplaced.case":"misplaced case",
         "msg.no.colon.prop":"missing : in object property definition",
         "msg.no.brace.switch":"missing { in switch",
         "msg.bad.continue":"incorrect use of continue",
         "msg.illegal.character":"illegal character",
         "msg.reserved.id":"identifier is a reserved word",
         "msg.bad.break.continue":"incorrect use of break or continue",
         "msg.unreachable.code":"unreachable code",
         "msg.bad.prop":"invalid property id",
         "msg.no.name.after.dot":"missing name after . operator",
         "msg.no.paren":"missing ) in parenthetical",
         "msg.misplaced.right.brace":"misplaced }",
         "msg.unreachable.stmts.in.switch":"unreachable code in switch statement",
         "msg.XML.bad.form":"illegally formed XML syntax",
         "msg.dup.label":"duplicatet label",
         "msg.no.semi.stmt":"missing ; before statement",
         "msg.class.not.supported":"class not supported",
         "msg.no.colon.cond":"missing : in conditional expression",
         "msg.bad.number.base":"incorrect number base",
         "msg.missing.exponent":"missing exponent",
         "msg.case.no.colon":"missing : after case expression",
         "msg.no.name.after.xmlAttr":"missing name after .@",
         "msg.no.brace.prop":"missing } after property list",
         "msg.unterminated.re.lit":"unterminated regular expression literal",
         "msg.invalid.escape":"invalid Unicode escape sequence",
         "msg.unterminated.comment":"unterminated comment",
         "msg.invalid.re.flag":"invalid flag after regular expression",
         "msg.caught.nfe":"number format error",
         "msg.not.assignable":"not assignable",
         "msg.unexpected.eof":"Unexpected end of file",
         "msg.no.brace.body":"missing \'{\' before function body",
         "msg.undef.label":"undefined labe",
         "msg.function.expr.not.supported":"function expression is not supported",
         "msg.missing.function.name":"missing function name",
         "msg.syntax":"syntax error",
         "msg.unterminated.string.lit":"unterminated string literal",
         "msg.no.bracket.arg":"missing ] after element list",
         "msg.bad.namespace":"not a valid default namespace statement. Syntax is: default xml namespace : EXPRESSION;",
         "msg.no.bracket.index":"missing ] in index expression",
         "msg.no.name.after.coloncolon":"missing name after ::",
         "msg.no.paren.for":"missing ( after for",
         "msg.no.paren.after.parms":"missing ) after formal parameters"
      };
      
      private static var _curEnv:Env;
       
      
      private var thisObject_getters:Object;
      
      private var scopeChain:Array;
      
      private var context:Object;
      
      private var thisObject_setters:Object;
      
      private var thisObject:Object;
      
      private var result:Object;
      
      public function Env(param1:Object, param2:Object)
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         super();
         this.thisObject = param1;
         this.context = param2;
         this.scopeChain = [param2];
         thisObject_setters = {};
         thisObject_getters = {};
         if(param1)
         {
            this.scopeChain.push(param1);
            if(param1.prototype != null)
            {
               this.scopeChain.push(param1.prototype);
            }
            _loc3_ = describeType(param1);
            for each(_loc4_ in _loc3_.accessor)
            {
               _loc5_ = _loc4_.@access;
               if(_loc5_ == "readwrite")
               {
                  thisObject_setters[_loc4_.@name] = thisObject_getters[_loc4_.@name] = true;
               }
               else if(_loc5_ == "readonly")
               {
                  thisObject_getters[_loc4_.@name] = true;
               }
               else if(_loc5_ == "writeonly")
               {
                  thisObject_setters[_loc4_.@name] = true;
               }
            }
         }
         else
         {
            thisObject_setters = thisObject_getters;
         }
         this.scopeChain.push(_global);
      }
      
      public static function getClass(param1:String) : Class
      {
         var _loc2_:* = _global[param1];
         if(_loc2_ == null)
         {
            return null;
         }
         if(_loc2_ is Class)
         {
            return _loc2_ as Class;
         }
         if(_loc2_ is Array)
         {
            _loc2_ = (_loc2_ as Array)[0];
            if(_loc2_ is Class)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function getProperty(param1:*) : Object
      {
         return _curEnv.getProperty(param1);
      }
      
      public static function isInDocQuery() : Boolean
      {
         var _loc1_:* = _curEnv.scopeChain[0];
         return _loc1_ is XML || _loc1_ is XMLList;
      }
      
      public static function reportWarning(... rest) : void
      {
         outputFunction("[D:warn ] " + getMessage.apply(null,rest));
      }
      
      public static function display(param1:String) : void
      {
         outputFunction(param1);
      }
      
      public static function run(param1:Block, param2:Object = null, param3:Object = null) : Object
      {
         var prgm:Block = param1;
         var thisObj:Object = param2;
         var context:Object = param3;
         var env:Env = new Env(thisObj,context != null?context:{});
         if(prgm)
         {
            try
            {
               pushEnv(env);
               prgm.run();
               return env.returnValue;
            }
            finally
            {
               while (popEnv()) {}
            }
         }
         return null;
      }
      
      public static function importClass(param1:Class, param2:String = null) : void
      {
         if(param2 == null)
         {
            param2 = describeType(param1).@name;
         }
         var _loc3_:Array = param2.split(/\./g);
         param2 = _loc3_[_loc3_.length - 1];
         importGlobal(param2,param1);
      }
      
      public static function getThis() : Object
      {
         return _curEnv.thisObject;
      }
      
      public static function setProperty(param1:*, param2:Object) : void
      {
         _curEnv.setProperty(param1,param2);
      }
      
      public static function printf(... rest) : void
      {
         display(getMessageAsIs.apply(null,rest));
      }
      
      private static function popEnv() : void
      {
         stack.pop();
         if(stack.length > 0)
         {
            _curEnv = stack[stack.length - 1];
         }
         else
         {
            _curEnv = null;
         }
      }
      
      public static function importFunction(param1:String, param2:Function) : void
      {
         var r:Array=param1.split(/\./g);
         importGlobal(r[r.length-1],param2);
      }
      
      public static function setReturnValue(param1:Object) : void
      {
         _curEnv.returnValue = param1;
      }
      
      public static function getMessage(... rest) : String
      {
         if(rest.length > 0)
         {
            rest[0] = idToMessage(rest[0]);
         }
         return getMessageAsIs.apply(null,rest);
      }
      
      public static function setOverrideGlobalOption(param1:int) : void
      {
         _overrideGlobalOption = param1;
      }
      
      private static function importGlobal(param1:String, param2:*) : void
      {
         if(_overrideGlobalOption != D.OVERRIDE_GLOBAL_OVERRIDE)
         {
            if(_global[param1])
            {
               switch(_overrideGlobalOption)
               {
                  case D.OVERRIDE_GLOBAL_WARN:
                     reportWarning("msg.override.global.name",param1);
                     break;
                  case D.OVERRIDE_GLOBAL_ERROR:
                     throw new RTError("msg.override.global.name",param1);
               }
            }
         }
         _global[param1] = param2;
      }
      
      public static function getReturnValue() : Object
      {
         return _curEnv.returnValue;
      }
      
      public static function getMessageAsIs(... rest) : String
      {
         switch(rest.length)
         {
            case 0:
               return "";
            case 1:
               return String(rest[0]);
            default:
               return Util.substitute.apply(null,rest);
         }
      }
      
      public static function popObject() : *
      {
         return _curEnv.popObject();
      }
      
      private static function idToMessage(param1:String) : String
      {
         var _loc2_:String = __errors[param1] as String;
         return _loc2_ == null?param1:_loc2_;
      }
      
      private static function pushEnv(param1:Env) : void
      {
         stack.push(_curEnv = param1);
      }
      
      public static function reportError(... rest) : void
      {
         outputFunction("[D:error] " + getMessage.apply(null,rest));
      }
      
      public static function debug(... rest) : void
      {
         outputFunction("[D:debug] " + getMessage.apply(null,rest));
      }
      
      public static function pushObject(param1:*) : void
      {
         _curEnv.pushObject(param1);
      }
      
      public static function peekObject() : *
      {
         return _curEnv.scopeChain[0];
      }
      
      public static function importStaticMethods(param1:Class, param2:* = null) : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc3_:XML = describeType(param1);
         for each(_loc4_ in _loc3_.method)
         {
            _loc5_ = _loc4_.@name;
            if(param2)
            {
               if(param2 is RegExp)
               {
                  if(!_loc5_.match(param2 as RegExp))
                  {
                     _loc5_ = null;
                  }
               }
               else if(param2 is Array)
               {
                  if((param2 as Array).indexOf(_loc5_) < 0)
                  {
                     _loc5_ = null;
                  }
               }
               else if(_loc5_ != param2)
               {
                  _loc5_ = null;
               }
            }
            if(_loc5_)
            {
               importFunction(_loc5_,param1[_loc5_]);
            }
         }
      }
      
      function set returnValue(param1:Object) : void
      {
         result = param1;
      }
      
      function get returnValue() : Object
      {
         return result;
      }
      
      function getProperty(param1:*) : Object
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in scopeChain)
         {
            if(_loc2_.hasOwnProperty(param1))
            {
               return _loc2_[param1];
            }
         }
         if(thisObject != null && thisObject_getters[param1])
         {
            return thisObject[param1];
         }
         return null;
      }
      
      function popObject() : *
      {
         return scopeChain.shift();
      }
      
      function setProperty(param1:*, param2:*) : void
      {
         var _loc3_:* = undefined;
         for each(_loc3_ in scopeChain)
         {
            if(_loc3_.hasOwnProperty(param1))
            {
               _loc3_[param1] = param2;
               return;
            }
         }
         if(thisObject != null && thisObject_setters[param1])
         {
            thisObject[param1] = param2;
         }
         else
         {
            context[param1] = param2;
         }
      }
      
      function pushObject(param1:*) : void
      {
         scopeChain.unshift(param1);
      }
   }
}