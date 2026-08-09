import React, { useState, useEffect, useRef } from 'react';
import { X, Save, Trash2, Code, LogOut, Undo, Redo } from 'lucide-react';
import { UIElement } from '../types';
import { getMethodsForComponent, MethodSignature } from '../utils/componentDefinitions';

interface MethodsMenuProps {
  element: UIElement;
  isOpen: boolean;
  onClose: () => void;
  onSave: (elementId: string, methods: Record<string, string>) => void;
}

const MethodsMenu: React.FC<MethodsMenuProps> = ({ element, isOpen, onClose, onSave }) => {
  const [selectedMethod, setSelectedMethod] = useState<MethodSignature | null>(null);
  const [code, setCode] = useState('');
  const [methods, setMethods] = useState<Record<string, string>>({});
  
  // History Management
  const [history, setHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const isUndoRedoAction = useRef(false);

  useEffect(() => {
    if (element) {
      setMethods(element.props.methods || {});
      setSelectedMethod(null);
      setCode('');
      setHistory([]);
      setHistoryIndex(-1);
    }
  }, [element]);

  // Update history when code changes
  useEffect(() => {
      if (selectedMethod) {
          if (!isUndoRedoAction.current) {
               // If it's a new change, push to history
               // Debouncing could be added here for performance if needed
               const currentHistory = history.slice(0, historyIndex + 1);
               if (currentHistory[currentHistory.length - 1] !== code) {
                   setHistory([...currentHistory, code]);
                   setHistoryIndex(prev => prev + 1);
               }
          }
          isUndoRedoAction.current = false;
      }
  }, [code, selectedMethod]); // Dependency on code means every keystroke updates history. For a text editor, usually we debounce.

  const handleUndo = () => {
      if (historyIndex > 0) {
          isUndoRedoAction.current = true;
          setHistoryIndex(prev => prev - 1);
          setCode(history[historyIndex - 1]);
      }
  };

  const handleRedo = () => {
      if (historyIndex < history.length - 1) {
          isUndoRedoAction.current = true;
          setHistoryIndex(prev => prev + 1);
          setCode(history[historyIndex + 1]);
      }
  };

  const getStub = (name: string) => {
      switch (name) {
          case 'Paint': return `    -- Arguments: self, w, h
    if self:IsHovered() then
        draw.RoundedBox(0, 0, 0, w, h, Color(220, 220, 220, 255))
    else
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255))
    end`;
          case 'PaintOver': return `    -- Draw on top of the panel and its children
    surface.SetDrawColor(255, 255, 255, 50) -- White with low alpha
    surface.DrawOutlinedRect(0, 0, w, h)`;
          case 'Think': return `    -- Logic to run every frame
    -- Example: self:SetPos(self:GetX() + 1, self:GetY())`;
          case 'OnMousePressed': return `    -- Arguments: self, keyCode
    if keyCode == MOUSE_LEFT then
        print("Left clicked on " .. tostring(self))
    elseif keyCode == MOUSE_RIGHT then
        print("Right clicked on " .. tostring(self))
    end`;
          case 'OnMouseReleased': return `    -- Arguments: self, keyCode
    print("Mouse released:", keyCode)`;
          case 'OnMouseDoubleClick': return `-- print("Double click on", self)`;
          case 'OnCursorEntered': return `    -- Called when cursor enters the panel
    print("Cursor entered " .. tostring(self))`;
          case 'OnCursorExited': return `    -- Called when cursor leaves the panel
    print("Cursor exited " .. tostring(self))`;
          case 'OnRemove': return `    -- Cleanup code when the panel is removed
    print("Panel removed:", self)`;
          case 'OnDragDrop': return `-- local droppedPanel = data
-- Handle drag and drop logic here`;
          case 'SetKeyboardInput': return `-- self:SetKeyboardInputEnabled(b)`;
          case 'OnDraw': return `-- Custom drawing logic here`;
          case 'GetSize': return `    -- Return the element's width and height
    return self:GetWide(), self:GetTall()`;
          case 'GetWide': return `    -- Return the element's width
    return self:GetWide()`;
          case 'SetSize': return `    -- Update the element's width and height
    self:SetSize(w, h)`;
          case 'SetPos': return `    -- Update the element's position
    self:SetPos(x, y)`;
          case 'SetText': return `    -- Set the text of the element
    self:SetText(text)`;
          case 'SetChecked': return `    -- Set the checkbox state
    self:SetChecked(checked)`;
          case 'SetEnabled': return `    -- Set enabled state
    self:SetEnabled(enabled)`;
          case 'SetVisible': return `    -- Sets whether the panel is visible
    self.BaseClass.SetVisible(self, visible)
    if visible then
        -- Logic when shown
    else
        -- Logic when hidden
    end`;
          default: return '';
      }
  };

  const handleMethodClick = (method: MethodSignature) => {
    // Save current buffer to local state before switching
    if (selectedMethod) {
        setMethods(prev => ({ ...prev, [selectedMethod.name]: code }));
    }
    
    setSelectedMethod(method);
    
    // Load existing code or stub
    const initialCode = methods[method.name] !== undefined ? methods[method.name] : getStub(method.name);
    setCode(initialCode);
    setHistory([initialCode]);
    setHistoryIndex(0);
  };

  const handleSave = () => {
     if (selectedMethod) {
         const newMethods = { ...methods, [selectedMethod.name]: code };
         setMethods(newMethods);
         onSave(element.id, newMethods);
     }
  };

  const handleClear = () => {
      setCode('');
      // Should clear update history?
  };
  
  const handleClose = () => {
      onClose();
  }

  if (!isOpen) return null;

  const availableMethods = getMethodsForComponent(element.type);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm">
      <div className="bg-neutral-900 border border-neutral-700 rounded-lg shadow-2xl w-[800px] h-[600px] flex flex-col overflow-hidden">
        {/* Header */}
        <div className="h-12 border-b border-neutral-700 flex items-center justify-between px-4 bg-neutral-800">
          <div className="flex items-center gap-2">
            <Code className="text-blue-400 w-5 h-5" />
            <span className="font-bold text-white">Methods: {element.props.variableName} ({element.type})</span>
          </div>
          <button onClick={onClose} className="p-1.5 hover:bg-neutral-700 rounded-md transition-colors text-neutral-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex flex-1 overflow-hidden">
          {/* Sidebar */}
          <div className="w-64 border-r border-neutral-700 flex flex-col bg-neutral-900 overflow-y-auto">
            <div className="p-2 space-y-1">
              {availableMethods.map((method) => {
                  const hasCode = methods[method.name] && methods[method.name].trim().length > 0;
                  return (
                    <button
                        key={method.name}
                        onClick={() => handleMethodClick(method)}
                        className={`w-full text-left px-3 py-2 rounded text-sm font-mono transition-colors flex items-center justify-between
                        ${selectedMethod?.name === method.name 
                            ? 'bg-blue-600 text-white' 
                            : 'text-neutral-400 hover:bg-neutral-800 hover:text-neutral-200'}`}
                    >
                        <span>{method.name}</span>
                        {hasCode && <div className="w-1.5 h-1.5 rounded-full bg-green-400"></div>}
                    </button>
                  );
              })}
            </div>
          </div>

          {/* Editor Area */}
          <div className="flex-1 flex flex-col bg-[#1e1e1e]">
            {selectedMethod ? (
                <>
                    <div className="p-2 bg-neutral-800 border-b border-neutral-700 flex justify-between items-center">
                        <div className="flex flex-col">
                            <div className="font-mono text-sm text-green-400">
                                function {element.props.variableName}:{selectedMethod.name}({selectedMethod.args.join(', ')})
                            </div>
                            {selectedMethod.description && (
                                <div className="text-[10px] text-neutral-500">{selectedMethod.description}</div>
                            )}
                        </div>
                        <div className="flex gap-1">
                             <button onClick={handleUndo} disabled={historyIndex <= 0} className="p-1 text-neutral-400 hover:text-white disabled:opacity-30 rounded hover:bg-neutral-700"><Undo className="w-4 h-4"/></button>
                             <button onClick={handleRedo} disabled={historyIndex >= history.length - 1} className="p-1 text-neutral-400 hover:text-white disabled:opacity-30 rounded hover:bg-neutral-700"><Redo className="w-4 h-4"/></button>
                        </div>
                    </div>
                    
                    <textarea 
                        value={code}
                        onChange={(e) => setCode(e.target.value)}
                        className="flex-1 bg-[#1e1e1e] text-neutral-200 p-4 font-mono text-sm resize-none focus:outline-none leading-relaxed"
                        placeholder="-- Enter GLua code here..."
                        spellCheck={false}
                    />

                    <div className="p-3 border-t border-neutral-700 bg-neutral-800 flex justify-end gap-3">
                        <button 
                            onClick={handleSave}
                            className="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-500 text-sm font-medium flex items-center gap-1.5"
                        >
                            <Save className="w-4 h-4" /> Save
                        </button>
                        <button 
                            onClick={handleClear}
                            className="px-4 py-2 rounded bg-neutral-700 text-neutral-300 hover:bg-neutral-600 text-sm font-medium flex items-center gap-1.5"
                        >
                            <Trash2 className="w-4 h-4" /> Clear
                        </button>
                        <button 
                            onClick={handleClose}
                            className="px-4 py-2 rounded bg-neutral-800 border border-neutral-600 text-neutral-300 hover:bg-neutral-700 text-sm font-medium flex items-center gap-1.5"
                        >
                            <LogOut className="w-4 h-4" /> Close
                        </button>
                    </div>
                </>
            ) : (
                <div className="flex-1 flex flex-col items-center justify-center text-neutral-500">
                    <Code className="w-12 h-12 mb-3 opacity-20" />
                    <p>Select a method to edit code</p>
                </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MethodsMenu;